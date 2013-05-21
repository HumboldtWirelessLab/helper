clear all; 
close all;

%% ------------------ Simulation Configuration  --------------------------------------------------
simulation_start = 0; % 0:= off; 1:= start new simulation
evaluation_simulation_activated = 1; % 0:= off; 1:= start evaluation for simulation 
evaluation_mechanismen_80211 = 1; % 0:= off 1:= start evaluation for the IEEE 802.11-mechanismen, e.g. aatarate and framesize and RTS/CTS
evaluation_model_birthday_problem_activated = 1; % 0:= off; 1:=start evaluation for the birthday problem
metrics_write_on = 0; % 0:= off; 1:= on
%simulation_of_collision = 1; % 0:= off (default), 1:= read from csv-file, 2:= new simulation
%packet_delivery_limit = 100;
number_of_simulation = 1000;
no_backoff_window_size_max =3100;
vector_contention_window_sizes = 0:1:no_backoff_window_size_max;
no_neighbours_max = 100;
vector_neighbours = 0:1:no_neighbours_max;
folder_name_1 = 'messungen/v1';
folder_name_2 = 'messungen/v2';
folder_name_3 = 'messungen/v3';
folder_name_4 = 'messungen/v4';
folder_name_5 = 'messungen/v7';
folder_name_6 = 'messungen/v8';
folder_name_7 = 'messungen/v9';
folder_name_8 = 'messungen/v10';
folder_name_9 ='messungen/v5';
folder_name_10 = 'messungen/v6';
folder_name =folder_name_2;
%number_of_simulation = 100;
file_directory_collision_air_capacity = sprintf('%s/%s/%s',folder_name,'collision','air_capacity');
file_directory_collision_efficiency = sprintf('%s/%s/%s',folder_name,'collision','efficiency');
file_directory_collision_backoff = sprintf('%s/%s/%s',folder_name,'collision','backoff');

simulation_results_write_on = 1; % 0:= off (default), 1:= write simulation results into csv-file
%evaluation_packets_successful_delivered_read_3D_on = 0; % 0:= 0ff; 1:= On
evaluation_figure_on = 1; % 0:= off; 1:= on
evaluation_figure_comparison_points_on = 0; %0:= Off; 1:= On


%% ----------- Birthday Problem Configuration  -------------------------
%packet_loss_upper_limit = 0.1; %10percent packet loss
vector_packet_loss_upper_limit = [0.02, 0.05, 0.10, 0.2, 0.3];
%----------- Figure init  -------------------------
figure_number = 0;

%% ----------- General IEEE 802.11 MAC-Layer Configuration  -------------------------
use_ism_bandwith_ghz = 0; % 0:= 2,4 GHz; 1:= 5 GHz; 2:= 2,4 GHz and 5 GHz
number_of_antennas = 1; % Antennas:= Default-Value = 1 for 802.11n there can be more
use_rts_cts = 0; % 0:= do not use; 1:=use RTS/CTS (exists at 802.11g and higher)
if (use_rts_cts == 1)   
    fileanme_collision_air_capacity = 'rts_collison_air_capacity';
    fileanme_collision_efficiency = 'rts_collison_efficiency';
    fileanme_collision_backoff = 'rts_collision_backoff';
else
    fileanme_collision_air_capacity = 'collison_air_capacity';
    fileanme_collision_efficiency = 'collison_efficiency';
    fileanme_collision_backoff = 'collision_backoff';
end
    %fileanme_collision_air_capacity = sprintf('',fileanme_collision_air_capacity);
    %fileanme_collision_efficiency = ;
    %fileanme_collision_backoff = ;
%% ----------- IEEE 802.11 MAC-Layer Configuration  -------------------------
is_Address4_requiered = 0; % 1:= yes, else no
use_greenfield = 1; % 0:= off; 1:= on
use_dsss_ofdm = 0; % 0:= off; 1:= on

%% ----------- IEEE 802.11n MAC-Layer Configuration  -------------------------
use_ieee80211n_mac = 0;% 0:= off (IEEE 802.11 MAC layer is used); 1:= on

use_bandwidth_40_MHz = 0; % 0:= 20 MHz; 1:=40MHz
use_short_guard_interval = 0; % 0:= off, 1:= on 
is_ht_required = 0; % 0:= off, 1:= on 
is_frame_body_8_kb = 0; % 0:= off, 1:= on 
is_a_msdu_used = 0; % 0:= off, 1:= on 
is_a_mpdu_used = 0; % 0:= off, 1:= on 
number_of_msdus_in_a_msdus = 0;
number_of_mpdus_in_a_mpdus = 0;

%% ------------ Rate Configuration ----------------------------------------
letter_of_standards = {'original','a','b','g','n'};
[ vector_rates_80211 ]  = func_rates_standard_supported(letter_of_standards{1,4});
vector_rates_data = vector_rates_80211;
vector_rates_data = [1,6,24,54];
vector_rates_ack = min(vector_rates_80211);
vector_rates_rts = min(vector_rates_80211);%vector_rates_80211a_mandatory;%[1,2];
vector_rates_cts=  min(vector_rates_80211);%vector_rates_80211a_mandatory;%[1,2];

%% ----------------- MSUD-Size Configuration -------------------------------
vector_msdu_sizes = [500, 1500, 3000, 8000]; %[Bytes]; size depend from higher layer; assuming a TCP/IP-Layer which limit the payload to 1500; important:"calculate in byte"
%% -------------------- Simulation  start ---------------------------------
if (simulation_start == 1)
    %simulation_of_collision = 2; %new simulation
    %[matrix_collision,matrix_collision_likelihood,no_neighbours_max,no_backoff_window_size_max, matrix_counter_slots] = func_simulation(simulation_of_collision,vector_backoff,no_neighbours_max,packet_delivery_limit,number_of_simulation,folder_name,write_simulation_results_2_csv)
    %func_simulation(simulation_of_collision,vector_backoff,vector_neighbours,simulation_packets_successful_delivered,number_of_simulation,folder_name,simulation_results_write_on);  
    [matrix_packets_delivered_3D, matrix_3D_col_occured_simulation_neighbour_backoff_global,matrix_slot_time_global_3D,no_neighbours_max,no_backoff_window_size_max] = func_simulation(vector_contention_window_sizes,vector_neighbours,number_of_simulation,folder_name,simulation_results_write_on);
end

%% ------------------- Evaluation start -----------------------------------
evaluation_on = 0; % 0:= off; 1:= start evaluation
if (evaluation_simulation_activated == 1 || evaluation_mechanismen_80211 == 1 || evaluation_model_birthday_problem_activated == 1)
    evaluation_on = 1; 
end

if (evaluation_on == 1)
    if (evaluation_simulation_activated == 1)
        if (simulation_start == 0)
    %------------------ Filenames -----------------------------------------    
            filename_matrix_sim_packets_delivery_3D_counter_global = 'sim_matrix_results_collision_simulation_neighbour_backoff_global';
            filename_matrix_sim_counter_collision_3D = 'sim_matrix_counter_collision_sim_neighbour_backoff_global';
            filename_matrix_sim_neighbour_backoff_global_3D_per_station = 'sim_matrix_col_occured_sim_neighbour_backoff_global_per_station';
            filename_simulation_configuration = 'simulation_configuration.csv';          
            %------------ Simulation Results: collision calculation global and per station -----------
            [number_of_simulation] = func_simulation_configuration_get(folder_name,filename_simulation_configuration);
            %------ Results per Station ------------
            [matrix_packets_delivered_3D] = func_sim_packets_delivered_3D_global_get(folder_name,filename_matrix_sim_packets_delivery_3D_counter_global,number_of_simulation);       
            [matrix_3D_col_occured_simulation_neighbour_backoff_global] = func_sim_collision_3D_global_get(folder_name,filename_matrix_sim_counter_collision_3D,number_of_simulation);
            % TODO: matrix_slot_time_global_3D = func_sim_packets_delivered_3D_global_get(folder_name,filename_matrix_sim_counter_slots_global_3D,number_of_simulation);
            filename_matrix_sim_counter_slots_global = 'sim_counter_slots_global.csv';% TODO:= siehe Zeile 102
            matrix_slot_time_global_3D = func_sim_collision_slots_global_get(folder_name,filename_matrix_sim_counter_slots_global,number_of_simulation);%TODO:= siehe Zeile 102
        end

        %------ Results for BSS (global) ------------
        [matrix_packets_delivered] = func_sim_packets_delivered_global_get(matrix_packets_delivered_3D);
        [matrix_3D_likelihood_simulation_collisions_percent_global] = func_sim_mean_per_station_calculation_3D(matrix_3D_col_occured_simulation_neighbour_backoff_global, matrix_packets_delivered_3D);
        [matrix_col_occured_mean_neighbour_backoff_global,matrix_likelihood_collisions_percent_global] = func_sim_collision_global_get(matrix_3D_col_occured_simulation_neighbour_backoff_global,matrix_3D_likelihood_simulation_collisions_percent_global);
        if (simulation_start == 0)
            [matrix_slot_time_global] = matrix_slot_time_global_3D;
        elseif (simulation_start == 1)
            [matrix_slot_time_global] = func_sim_packets_delivered_global_get(matrix_slot_time_global_3D);
        end
    %---------------------- Evaluation starts here ---------------------------
        [vector_slot_time_minimum_per_neighbour,vector_backoff_window_sizes_per_neighbour] = func_evaluation_matrix_search_4_minimum_greater_zero(matrix_slot_time_global);
        
        vector_neighbours=1:1:size(vector_backoff_window_sizes_per_neighbour,2);
        %test_find_backoff_optimal_on = 0;  
        %vector_backoff_window_sizes_standard = func_cw_vector_get(test_find_backoff_optimal_on,letter_of_standards{1,2}, no_backoff_window_size_max,use_greenfield);
        %[matrix_likelihood_collisions_sim_global] = func_sim_mean_globlal_calculation(, matrix_packets_delivered);
        [matrix_col_occured_simulation_3D_neighbour_backoff_per_station,matrix_likelihood_simulation_3D_collisions_percent_per_station] = func_sim_collision_3D_per_station_get(folder_name,filename_matrix_sim_neighbour_backoff_global_3D_per_station,number_of_simulation,matrix_packets_delivered_3D);
        [matrix_col_occured_mean_neighbour_backoff_per_station,matrix_likelihood_collisions_percent_per_station] = func_sim_collision_per_station_get(matrix_col_occured_simulation_3D_neighbour_backoff_per_station,matrix_likelihood_simulation_3D_collisions_percent_per_station);
        
        figure_number = 1;
        ticks_y_step_size = 2;
        legend_on = 0;
        vector_legend = 0;
        text_legend_title = '';
        text_label_y = '\bf{Backoff-Fenstergröße [Slots]}';
        text_title = 'Optimale Backoff-Fenstergrößen für min. globale Zeitschlitze';
        func_figure_birthday_problem_neighbours_backoff_window_sizes(figure_number,vector_neighbours, vector_backoff_window_sizes_per_neighbour,text_label_y,ticks_y_step_size,text_title,legend_on,vector_legend,text_legend_title);% Lookup-Table
        
        matrix_sim_likelihood_collisions_percent_per_station = matrix_likelihood_collisions_percent_per_station * 100;
        matrix_sim_likelihood_collisions_percent_global = matrix_likelihood_collisions_percent_global * 100;
        no_backoff_window_size_max = size(matrix_col_occured_mean_neighbour_backoff_per_station,2);
        no_neighbours_max =  size(matrix_col_occured_mean_neighbour_backoff_per_station,1);
        no_backoff_window_size_min = 1; % TODO: start at 0 or startpoint from simulation
        vector_contention_window_sizes = no_backoff_window_size_min:1:no_backoff_window_size_max; % Vector for different contention window sizes
        vector_neighbours = 1:1:no_neighbours_max; 
    end
    
    %------------------- Backoff with birthday problem   -------------------------------------
    if (evaluation_model_birthday_problem_activated == 1)
        %if (evaluation_simulation_activated == 1)
        %    no_backoff_window_size_max = size(matrix_col_occured_mean_neighbour_backoff_per_station,2);
        %    no_neighbours_max =  size(matrix_col_occured_mean_neighbour_backoff_per_station,1);
        %end
        %no_backoff_window_size_min = 1; % TODO: start at 0 or startpoint from simulation
        %vector_birthday_problem_cw_sizes = no_backoff_window_size_min:1:no_backoff_window_size_max; % Vector for different contention window sizes
        %vector_birthday_problem_neighbours = 1:1:no_neighbours_max; %vector for different neighbours
    %---------------- Birthday-Problem calculation ------------------------
        [matrix_birthday_problem_packet_loss_classic] = func_birhtday_problem_packetloss_classic_2(vector_contention_window_sizes,vector_neighbours);
        [matrix_birthday_problem_packet_loss] = func_birhtday_problem_packetloss_2(vector_contention_window_sizes,vector_neighbours);
        [matrix_packet_loss_neighbours_backoff_windows_approx_classic] = func_backoff_approximation_classic(vector_packet_loss_upper_limit,vector_neighbours);
        [matrix_packet_loss_neighbours_backoff_windows_approximation] = func_backoff_approximation(vector_packet_loss_upper_limit,vector_neighbours);
        %[matrix_packet_loss_neighbours_backoff_windows_approximation_2] = func_backoff_approximation_2(vector_packet_loss_upper_limit,vector_neighbours);
        %[matrix_packet_loss_neighbours_backoff_windows_approximation_3] = func_backoff_approximation_3(vector_packet_loss_upper_limit,vector_neighbours);

    %------------ limit packet loss likelihood calculation and therefore search for packet_loss_upper_limit  --------
        if (vector_packet_loss_upper_limit(1,1) == -1)
            matrix_packet_loss_neighbours_backoff_birthday_problem_classic = matrix_birthday_problem_packet_loss_classic;
            matrix_packet_neighbours_backoff_birthday_problem_intuitiv = matrix_birthday_problem_packet_loss;
            vector_of_successful_conditions_classic = -1;
            vector_of_successful_conditions_intuitiv = -1;
        else 
            [matrix_packet_loss_neighbours_backoff_birthday_problem_classic,vector_of_successful_conditions_classic] = func_birthday_problem_packet_loss_limit(matrix_birthday_problem_packet_loss_classic,vector_neighbours,vector_packet_loss_upper_limit);
            [matrix_packet_neighbours_backoff_birthday_problem_intuitiv,vector_of_successful_conditions_intuitiv] = func_birthday_problem_packet_loss_limit(matrix_birthday_problem_packet_loss,vector_neighbours,vector_packet_loss_upper_limit);
        end
        matrix_birthday_problem_packet_loss_classic_percent = matrix_birthday_problem_packet_loss_classic * 100;
        matrix_birthday_problem_packet_loss_percent = matrix_birthday_problem_packet_loss * 100; 
        [error_packet_loss_series_classic] = func_error_diff_calc(matrix_packet_loss_neighbours_backoff_birthday_problem_classic,matrix_packet_loss_neighbours_backoff_windows_approx_classic,vector_of_successful_conditions_classic');
        [error_packet_loss_series] = func_error_diff_calc(matrix_packet_neighbours_backoff_birthday_problem_intuitiv,matrix_packet_loss_neighbours_backoff_windows_approximation,vector_of_successful_conditions_intuitiv');
    %---------------- Generate Figures for the birthday problem ------------------------------------
        if (figure_number == 0) 
            figure_number = 1;
        else
            figure_number = figure_number + 1;
        end
        test_find_backoff_optimal_on = 0;  
        vector_backoff_window_sizes_standard = func_cw_vector_get(test_find_backoff_optimal_on,letter_of_standards{1,2}, no_backoff_window_size_max,use_greenfield);
        vector_legend_pos(1,1) = 'n';
        vector_legend_pos(1,2) = 'w';
        [handler_figure_1] = func_figure_backoff_window_sizes_neighbours_different_losses(figure_number,matrix_packet_loss_neighbours_backoff_birthday_problem_classic,vector_packet_loss_upper_limit, vector_neighbours,vector_of_successful_conditions_classic',vector_backoff_window_sizes_standard,vector_legend_pos);
        figure_number = figure_number + 1;
        vector_legend_pos(1,1) = 'n';
        vector_legend_pos(1,2) = 'w';
        [handler_figure_2] = func_figure_backoff_window_sizes_neighbours_different_losses(figure_number,matrix_packet_neighbours_backoff_birthday_problem_intuitiv,vector_packet_loss_upper_limit,vector_neighbours,vector_of_successful_conditions_intuitiv',vector_backoff_window_sizes_standard,vector_legend_pos);
        figure_number = figure_number + 1;
        matrix_2_color = 'c';
        legend_change = 'n';
        legend_text1 = '\bf{Paketverlust [%] klassisch}';
        [handler_figure_3] = func_figure_backoff_window_sizes_neighbours_different_losses_2(figure_number,matrix_packet_loss_neighbours_backoff_birthday_problem_classic,matrix_packet_loss_neighbours_backoff_windows_approx_classic,matrix_2_color,vector_packet_loss_upper_limit,vector_neighbours,vector_of_successful_conditions_classic',vector_backoff_window_sizes_standard,legend_change,legend_text1);    
        figure_number = figure_number + 1;
        matrix_2_color = 'c';
        legend_change = 'n';
        legend_text1 = '\bf{Paketverlust [%] intuitiv}';
        [handler_figure_3_1] = func_figure_backoff_window_sizes_neighbours_different_losses_2(figure_number,matrix_packet_neighbours_backoff_birthday_problem_intuitiv,matrix_packet_loss_neighbours_backoff_windows_approximation,matrix_2_color,vector_packet_loss_upper_limit,vector_neighbours,vector_of_successful_conditions_intuitiv',vector_backoff_window_sizes_standard,legend_change,legend_text1);  
        figure_number = figure_number + 1;
        matrix_2_color = 'r';
        legend_change = 'b';
        
        vector_of_successful_conditions_classic2 = zeros(1,size(vector_of_successful_conditions_classic,2));
        zoom = 0;
        if (zoom == 1)
            vc = 1;
            for vc1 = 1:1:size(matrix_packet_loss_neighbours_backoff_birthday_problem_classic,1)
                for vc2 = 1:1:size(matrix_packet_loss_neighbours_backoff_birthday_problem_classic,2)
                    if (matrix_packet_loss_neighbours_backoff_birthday_problem_classic(vc1,vc2) <= 750 && matrix_packet_loss_neighbours_backoff_birthday_problem_classic(vc1,vc2) > 0)
                        vector_of_successful_conditions_classic2(1,vc) = vc2;
                    end
                end
                if (vector_of_successful_conditions_classic2(1,vc) > 25)
                    vector_of_successful_conditions_classic2(1,vc) = 25;
                end
                vc = vc + 1;
            end
        else
            vector_of_successful_conditions_classic2 = vector_of_successful_conditions_classic;
        end
        legend_text1 = '\bf{Paketverlust [%] klassisch}';
        [handler_figure_4] = func_figure_backoff_window_sizes_neighbours_different_losses_2(figure_number,matrix_packet_loss_neighbours_backoff_birthday_problem_classic,matrix_packet_neighbours_backoff_birthday_problem_intuitiv,matrix_2_color,vector_packet_loss_upper_limit,vector_neighbours,vector_of_successful_conditions_classic2',vector_backoff_window_sizes_standard,legend_change,legend_text1);   
        %figure_number = figure_number + 1; % it doesn't make sense
        %vector_axes_label_x = vector_packet_loss_upper_limit * 100;
        %label_x = 'Paketverlust [%]';
        %[handler_figure_5] = func_figure_birthday_problem_boxplot(figure_number,error_packet_loss_series,vector_of_successful_conditions_classic,vector_axes_label_x,label_x); 
    end
    
    %---------------- Generate Figures ------------------------------------
    if (evaluation_simulation_activated == 1 && evaluation_model_birthday_problem_activated == 1)
       vector_neighbours_filter=[1,5,9,15,20,25];
       vector_likelihood_filter=[5,10,20,30];
       [matrix_diff1] = func_comparison_differenz_euklid_2(matrix_sim_likelihood_collisions_percent_global,matrix_birthday_problem_packet_loss_classic_percent,vector_neighbours,vector_neighbours_filter,vector_likelihood_filter);
       [matrix_diff2] = func_comparison_differenz_euklid_2(matrix_sim_likelihood_collisions_percent_global,matrix_birthday_problem_packet_loss_percent,vector_neighbours,vector_neighbours_filter,vector_likelihood_filter);
       %[matrix_diff1] = func_comparison_diff_calc(matrix_sim_likelihood_collisions_percent_global,matrix_birthday_problem_packet_loss_percent,vector_neighbours,vector_neighbours_filter);
       %[matrix_diff2] = func_comparison_diff_calc(matrix_sim_likelihood_collisions_percent_global,matrix_birthday_problem_packet_loss_classic_percent,vector_neighbours,vector_neighbours_filter);
        %figure_number = 1;
        %func_figure_birthday_problem_neighbours_backoff_window_sizes(figure_number,vector_neighbours, vector_backoff_window_sizes_per_neighbour);% Lookup-Table
        %vector_neighbours_filter=1:5:size(vector_birthday_problem_neighbours,2);

        %figure_number = figure_number + 1;
%TODO:Debug        [handler_figure_01] = func_figure_backoff_window_size_likelihood_sim_calc_comparison(figure_number,matrix_plot_1,matrix_plot_2,vector_neighbours_filter);
        %figure_number = figure_number + 1;
%TODO:Debug        [handler_figure] = func_figure_likelihood_sim_calc_comparison(figure_number,matrix_plot_1,matrix_plot_2,vector_neighbours_filter);

        figure_number = figure_number + 1;
        label_x = 'Kollisionswkt. [%] (Kalkulation)';
        label_y = 'Kollisionswkt. [%] (Simulation)';
        [handler_figure_02] = func_figure_likelihood_sim_calc_comparison(figure_number,matrix_birthday_problem_packet_loss_classic_percent, matrix_sim_likelihood_collisions_percent_global,vector_neighbours,vector_neighbours_filter,label_x,label_y);
        figure_number = figure_number + 1;
        [handler_figure_021] = func_figure_likelihood_sim_calc_comparison(figure_number,matrix_birthday_problem_packet_loss_percent,matrix_sim_likelihood_collisions_percent_global,vector_neighbours,vector_neighbours_filter,label_x,label_y);
        figure_number = figure_number + 1;
        label_y = 'Kollisionswkt. [%] (Kalkulation)';
        label_x = 'Kollisionswkt. [%] (Simulation)';
        [handler_figure_022] = func_figure_likelihood_sim_calc_comparison(figure_number,matrix_sim_likelihood_collisions_percent_global, matrix_birthday_problem_packet_loss_classic_percent,vector_neighbours,vector_neighbours_filter,label_x,label_y);
        figure_number = figure_number + 1;
        [handler_figure_023] = func_figure_likelihood_sim_calc_comparison(figure_number,matrix_sim_likelihood_collisions_percent_global, matrix_birthday_problem_packet_loss_percent,vector_neighbours,vector_neighbours_filter,label_x,label_y);
        if (evaluation_figure_comparison_points_on)
            figure_number = figure_number + 1;
            [handler_figure_10] = func_figure_likelihood_sim_calc_comparison_points(figure_number,matrix_sim_likelihood_collisions_percent_per_station,matrix_birthday_problem_packet_loss_classic_percent);
        end
        %test_find_backoff_optimal_on = 0;  
        %vector_backoff_window_sizes_standard = func_cw_vector_get(test_find_backoff_optimal_on,letter_of_standards{1,2}, no_backoff_window_size_max,use_greenfield);
        %figure_number = figure_number + 1;
        %[handler_figure_1] = func_figure_backoff_window_sizes_neighbours_different_losses(figure_number,matrix_packet_loss_neighbours_backoff_birthday_problem_classic,vector_packet_loss_upper_limit,vector_of_successful_conditions_classic',vector_backoff_window_sizes_standard);
        %figure_number = figure_number + 1;
        %[handler_figure_3] = func_figure_backoff_window_sizes_neighbours_different_losses_2(figure_number,matrix_packet_loss_neighbours_backoff_birthday_problem_classic,matrix_packet_loss_neighbours_backoff_windows_approximation,vector_packet_loss_upper_limit,vector_of_successful_conditions_classic',vector_backoff_window_sizes_standard);    
        %figure_number = figure_number + 1;
        %[handler_figure_4] = func_figure_birthday_problem_classic_comparison(figure_number,matrix_birthday_problem_packet_loss_classic_percent,matrix_packet_loss_neighbours_backoff_windows_birthday_problem,vector_of_successful_conditions_classic',vector_of_successful_conditions');  
        %[handler_figure_1] = func_figure_birthday_problem_neighbours_backoff_window_sizes(figure_number,vector_neighbours, vector_backoff_window_sizes_per_neighbour,vector_backoff_window_sizes_standard);    end
        
        %debug_figures = 0;
        %if (debug_figures == 1) %TODO: überprüfen
            %figure_number = figure_number + 1;
            %[hfig_1] = func_figure_birthday_problem_backoff_collision(figure_number,matrix_backoff_windows, likelihood, vector_neighbours, vector_backoff_window_sizes_standard);
            %figure_number = figure_number + 1;
            %[handler_fig] = func_figure_birthday_problem_neighbours_collision(figure_number,matrix_neighbours, likelihood, vector_backoff_window_sizes, vector_neighbours);
        %end
    end


% ------------------------------ Evaluation of the IEEE 802.11-Mechanismen, e.g. datarate, framesize, RTS/CTS ------------------------     
    if (evaluation_simulation_activated == 1 && evaluation_mechanismen_80211 == 1)
        %simulation_packets_successful_delivered = 2;
        %for i = 1:1:size(vector_msdu_sizes,2)
             %[matrix_tmt_neighbours,matrix_tmt_backoff,matrix_tmt_collisions,matrix_tmt_collisions_percent,matrix_results_bandwidth_efficient,matrix_tmt_backoff_birthday_problem,matrix_tmt_backoff_birthday_problem_approximation,matrix_duration_delay,output_xml] = func_calculation_rates_msdu_sizes(matrix_sim_likelihood_collisions_percent_global,no_neighbours_max,no_backoff_window_size_max, matrix_counter_slots,frame_mac, frame_rts, frame_cts, frame_ack,vector_rates_data,vector_rates_ack,vector_rates_rts,vector_rates_cts,vector_msdu_sizes,simulation_packets_successful_delivered,packet_loss_upper_limit,use_rts_cts,use_greenfield,use_dsss_ofdm,use_ism_bandwith_ghz,use_bandwidth_40_MHz,number_of_antennas,use_short_guard_interval);
            %[matrix_tmt_neighbours,matrix_tmt_backoff,matrix_tmt_collisions,matrix_tmt_collisions_percent,matrix_results_bandwidth_efficient,matrix_tmt_backoff_birthday_problem,matrix_tmt_backoff_birthday_problem_approximation,matrix_duration_delay,output_xml] = func_calculation_rates_msdu_sizes(matrix_sim_likelihood_collisions_percent_global,vector_neighbours, matrix_slot_time_global,frame_mac, frame_rts, frame_cts, frame_ack,vector_rates_data,vector_rates_ack,vector_rates_rts,vector_rates_cts,vector_msdu_sizes,simulation_packets_successful_delivered,vector_packet_loss_upper_limit,use_rts_cts,use_greenfield,use_dsss_ofdm,use_ism_bandwith_ghz,use_bandwidth_40_MHz,number_of_antennas,use_short_guard_interval);
        vector_layer_mac_configuration = [is_Address4_requiered,use_rts_cts,use_greenfield,use_dsss_ofdm,use_ism_bandwith_ghz,use_bandwidth_40_MHz,number_of_antennas,use_short_guard_interval,is_ht_required,is_frame_body_8_kb,is_a_msdu_used, number_of_msdus_in_a_msdus, is_a_mpdu_used, number_of_mpdus_in_a_mpdus,use_ieee80211n_mac];
            %[matrix_tmt_air_capacity,matrix_tmt_backoff,matrix_tmt_collisions,matrix_tmt_collisions_percent,matrix_results_bandwidth_efficient,output_xml] = func_layer_mac(matrix_col_occured_mean_neighbour_backoff_global,vector_neighbours,vector_contention_window_sizes, matrix_slot_time_global,vector_rates_data,vector_rates_ack,vector_rates_rts,vector_rates_cts,vector_msdu_sizes,matrix_packets_delivered,is_Address4_requiered,use_rts_cts,use_greenfield,use_dsss_ofdm,use_ism_bandwith_ghz,use_bandwidth_40_MHz,number_of_antennas,use_short_guard_interval,is_ht_required,is_frame_body_8_kb,is_a_msdu_used, number_of_msdus_in_a_msdus, is_a_mpdu_used, number_of_mpdus_in_a_mpdus,use_ieee80211n_mac);
        [matrix_tmt_air_capacity_3D,matrix_tmt_backoff_3D,matrix_tmt_collisions_3D,matrix_tmt_collisions_percent_3D,matrix_results_bandwidth_efficient_3D,matrix_results_collisions_air_capacity_4D,matrix_results_collisions_efficiency_4D,matrix_results_collisions_backoff_4D,output_xml] = func_layer_mac(matrix_col_occured_mean_neighbour_backoff_global,vector_neighbours,vector_contention_window_sizes, matrix_slot_time_global,vector_rates_data,vector_rates_ack,vector_rates_rts,vector_rates_cts,vector_msdu_sizes,matrix_packets_delivered,vector_layer_mac_configuration,vector_packet_loss_upper_limit);
        if (metrics_write_on == 1)
            func_csvwrite_matrix_4D(file_directory_collision_air_capacity,fileanme_collision_air_capacity,matrix_results_collisions_air_capacity_4D);
            func_csvwrite_matrix_4D(file_directory_collision_efficiency,fileanme_collision_efficiency,matrix_results_collisions_efficiency_4D);
            func_csvwrite_matrix_4D(file_directory_collision_backoff,fileanme_collision_backoff,matrix_results_collisions_backoff_4D);
        end
            %
        debug_data_rate = 1;
        figure_save_on = 0;
       if (debug_data_rate == 1)
            rate = 1;
            [ vector_backoff_new,matrix_2d] = func_get_backoff_throughput(rate,matrix_tmt_backoff_3D,matrix_tmt_air_capacity_3D);
            figure_number = figure_number + 1;
            text_title = ' ';
            ticks_y_step_size = 5;
            ticks_y_max = 60;
            legend_on = 1;
            text_legend_title1 = '\bf{Datenraten [Mbps]}';
            vector_legend1 = vector_rates_data;
            text_legend_title2 = '\bf{MSDU-Größen [Bytes]}';
            vector_legend2 = vector_msdu_sizes;
            text_label_y = '\bf{Durchsatz [Mbps]}';
            text_label_x = '\bf{Backoff-Fenstergröße [Slots]}';
            %% TODO: Graphik
            %func_figure_evaluation_tmt_2D(figure_number,vector_backoff_new, matrix_2d,text_label_x, text_label_y,ticks_y_step_size,ticks_y_max,text_title,legend_on,vector_legend1,text_legend_title1,vector_legend2,text_legend_title2);

        %for i= 1:1:size(matrix_tmt_backoff_3D,1)
         %   [matrix_2d_tmt_backoff] = func_convert_matrix_3D_2_2D(matrix_tmt_backoff_3D,i); 
         %   [matrix_2d_tmt_air_capacity] = func_convert_matrix_3D_2_2D(matrix_tmt_air_capacity_3D,i);   
         %   figure_number = figure_number + 1;
         %   figure(figure_number)
         %   plot(matrix_2d_tmt_backoff,matrix_2d_tmt_air_capacity);
         %   title(sprintf('Rate:=%d',vector_rates_data(1,i))) 
         %   grid on
            %ticks_y_step_size = -1;
            %legend_on = 1;
            %vector_legend = vector_packet_loss_upper_limit * 100;
            %text_legend_title = 'Paketverluste [%]';
            %text_label_y = '\bf{Durchsatz [Mbps]}';
            %text_title = sprintf('Rate:=%d; MSDU-Größe:=%d',vector_rates_data(1,i),vector_msdu_sizes(1,j));
            %[handler_figure] = func_figure_plot_2D(figure_number,vector_no_neighbours, matrix_2d_air_capacity, matrix_2d_air_capacity_rts,text_label_y,ticks_y_step_size,text_title,legend_on,vector_legend,text_legend_title);% Lookup-Table
            %if (figure_save_on == 1)
            %    string = num2str(figure_number);
            %    file_na = sprintf('%s/evaluation_simulation_rts_cts_%s',file_directory_save_air_capacity,string);
            %    saveas(handler_figure,file_na,'epsc')
            %end
            %figure_number = figure_number + 1;
        %end
            figure_number = figure_number + 1;
            text_title = ' ';
            ticks_y_step_size = 5;
            ticks_y_max = 60;
            legend_on = 1;
            text_legend_title1 = '\bf{Datenraten [Mbps]}';
            vector_legend1 = vector_rates_data;
            text_legend_title2 = '\bf{MSDU-Größen [Bytes]}';
            vector_legend2 = vector_msdu_sizes;
            text_label_y = '\bf{Durchsatz [Mbps]}';
            text_label_x ='\bf{Anzahl von 802.11-Nachbarstationen}';
            func_figure_evaluation_tmt(figure_number,vector_neighbours, matrix_tmt_air_capacity_3D,text_label_x,text_label_y,ticks_y_step_size,ticks_y_max,text_title,legend_on,vector_legend1,text_legend_title1,vector_legend2,text_legend_title2);

            figure_number = figure_number + 1;
            text_title = ' ';
            ticks_y_step_size = -1;
            ticks_y_max = -1;
            legend_on = 1;
            text_legend_title1 = '\bf{Datenraten [Mbps]}';
            vector_legend1 = vector_rates_data;
            text_legend_title2 = '\bf{MSDU-Größen [Bytes]}';
            vector_legend2 = vector_msdu_sizes;
            text_label_y = '\bf{Backoff-Fenstergröße [Slots]}';
            text_label_x ='\bf{Anzahl von 802.11-Nachbarstationen}';
            func_figure_evaluation_tmt(figure_number,vector_neighbours, matrix_tmt_backoff_3D,text_label_x,text_label_y,ticks_y_step_size,ticks_y_max,text_title,legend_on,vector_legend1,text_legend_title1,vector_legend2,text_legend_title2);
            

            figure_number = figure_number + 1;
            text_title = ' ';
            ticks_y_step_size = -1;
            ticks_y_max = -1;
            legend_on = 1;
            text_legend_title1 = '\bf{Datenraten [Mbps]}';
            vector_legend1 = vector_rates_data;
            text_legend_title2 = '\bf{MSDU-Größen [Bytes]}';
            vector_legend2 = vector_msdu_sizes;
            text_label_y = '\bf{Kollisionen}';
            text_label_x ='\bf{Anzahl von 802.11-Nachbarstationen}';
            func_figure_evaluation_tmt(figure_number,vector_neighbours, matrix_tmt_collisions_3D,text_label_x,text_label_y,ticks_y_step_size,ticks_y_max,text_title,legend_on,vector_legend1,text_legend_title1,vector_legend2,text_legend_title2);

            figure_number = figure_number + 1;
            text_title = ' ';
            ticks_y_step_size = 10;
            ticks_y_max = 100;
            legend_on = 1;
            text_legend_title1 = '\bf{Datenraten [Mbps]}';
            vector_legend1 = vector_rates_data;
            text_legend_title2 = '\bf{MSDU-Größen [Bytes]}';
            vector_legend2 = vector_msdu_sizes;
            text_label_y = '\bf{Kollisionswahrscheinlichkeit}';
            text_label_x ='\bf{Anzahl von 802.11-Nachbarstationen}';
            func_figure_evaluation_tmt(figure_number,vector_neighbours, matrix_tmt_collisions_percent_3D,text_label_x,text_label_y,ticks_y_step_size,ticks_y_max,text_title,legend_on,vector_legend1,text_legend_title1,vector_legend2,text_legend_title2);

            figure_number = figure_number + 1;
            text_title = ' ';
            ticks_y_step_size = 10;
            ticks_y_max = 100;
            legend_on = 1;
            text_legend_title1 = '\bf{Datenraten [Mbps]}';
            vector_legend1 = vector_rates_data;
            text_label_x = '\bf{MSDU-Größen [Bytes]}';
            vector_legend2 = vector_msdu_sizes;
            text_label_y = '\bf{Effizienz [%]}';
            text_legend_title2 = '\bf{802.11-Nachbarstationen}';
            vector_neighbours_filter=[1,5,9,15,20,25];
            [matrix_results_bandwidth_efficient_3D_filtered] = func_sim_reduce_neighbours_3D(matrix_results_bandwidth_efficient_3D,vector_neighbours,vector_neighbours_filter);
            func_figure_evaluation_tmt_efficiency_msdu_sizes(figure_number,vector_msdu_sizes, matrix_results_bandwidth_efficient_3D_filtered,text_label_x,text_label_y,ticks_y_step_size,ticks_y_max,text_title,legend_on,vector_legend1,text_legend_title1,vector_neighbours_filter,text_legend_title2);

            %matrix_tmt_air_capacity2(:,:) = matrix_tmt_air_capacity(i,:,:);
            %figure_number = figure_number + 1;
            %text_title = sprintf('Für Datenrate %d [Mbps]',vector_rates_data(1,i));
            %ticks_y_step_size = 50;
            %legend_on = 1;
            %vector_legend = vector_msdu_sizes;
            %text_legend_title = 'MSDU-Größen [Bytes]';
            %text_label_y = '\bf{Durchsatz [Mbps]}';
            %func_figure_birthday_problem_neighbours_backoff_window_sizes(figure_number,vector_neighbours, matrix_tmt_air_capacity2,text_label_y, ticks_y_step_size,text_title,legend_on,vector_legend,text_legend_title);

        %end
      end
       % debug_msdu_sizes = 0;
       % if (debug_msdu_sizes == 1)
      %   for j = 1:1:size(vector_msdu_sizes,2)   

       %     matrix_tmt_backoff3(:,:) = matrix_tmt_backoff_3D(:,j,:);
       %     figure_number = figure_number + 1;
       %     text_title = sprintf('Für MSDU-Größe %d [Bytes]',vector_msdu_sizes(1,j));
       %     ticks_y_step_size = -1;
       %     legend_on = 1;
       %     vector_legend = vector_rates_data;
       %     text_legend_title = 'Datenraten [Mbps]';
       %     text_label_y = '\bf{Backoff-Fenstergröße [Slots]}';
       %     func_figure_birthday_problem_neighbours_backoff_window_sizes(figure_number,vector_neighbours, matrix_tmt_backoff3,text_label_y,ticks_y_step_size,text_title,legend_on,vector_legend,text_legend_title);
            

        %    matrix_tmt_air_capacity3(:,:) = matrix_tmt_air_capacity_3D(:,j,:);
        %    figure_number = figure_number + 1;
        %    text_title = sprintf('Für MSDU-Größe %d [Bytes]',vector_msdu_sizes(1,j));
        %    ticks_y_step_size = -1;
        %    legend_on = 1;
        %    vector_legend = vector_rates_data;
        %    text_legend_title = 'Datenraten [Mbps]';
        %    text_label_y = '\bf{Durchsatz [Mbps]}';
        %    func_figure_birthday_problem_neighbours_backoff_window_sizes(figure_number,vector_neighbours, matrix_tmt_air_capacity3,text_label_y,ticks_y_step_size,text_title,legend_on,vector_legend,text_legend_title);
         %end
        %end
    end
end


    %% For this backoff calculation, see formula (3) in paper: 
    %       Geng Cheng, Wei Liu, Yunzhao Li, Wenqing Cheng :
    %           "Spectrum Aware On-demand Routing in Cognitive Radio Networks"
debug = 0;
if (debug == 1)
    cw_min = 15;
    [ delay_backoff ] = func_medium_access_delay(number_of_contending_nodes, likelihood_collision, cw_min);
    [vector_neighbours_2, vector_backoff_birthday_problem_for_cw_min_2, vector_backoff_medium_access_delay,vector_backoff_window_sizes_per_neighbour_2,vector_backoff_window_sizes_per_neighbour_approximation_2] = func_birthday_problem_and_medium_access_delay_alignment (no_backoff_window_size_max,no_neighbours_max, cw_min,packet_loss_upper_limit);
end
 %   hold all
 %   plot(vector_neighbours,vector_backoff_window_sizes_per_neighbour)
 %   plot(vector_neighbours,vector_backoff_medium_access_delay)
    %plot(vector_birthday_problem_approximation_neighbours,vector_backoff_delay_old)
    %plot(vector_birthday_problem_approximation_neighbours,backoff_windows_slot_approximation)
%    plot(vector_neighbours,vector_backoff_window_sizes_per_neighbour_approximation)
%    grid on
%    xlabel('#Nachbarn')
%    ylabel('Backoff [Slots]')
    %legend('Backoff-Delay', 'Geburtstagsparadoxon','Location','NorthEastOutside')
%    legend('Geburtstagsparadoxon', 'Geburtstagsparadoxon-Approximiation','Location','NorthEastOutside')


%debug_saveas = 0;
%if(debug_saveas == 1)
%        directory = 'evaluation/';
%    [s,mess,messid] = mkdir(directory);
%    format ='png';
%    filename_1 = sprintf('%sbackoff_neighbours_calc.png',directory);
%    filename_2 = sprintf('%sbackoff_neighbours_approx.png',directory);
%    filename_3 = sprintf('%sbackoff_neighbours_calc_approx.png',directory);
    
%    saveas(handler_figure,filename_1,format)
%    saveas(handler_figure_2,filename_2,format)
%    saveas(handler_figure_3,filename_3,format)
%end