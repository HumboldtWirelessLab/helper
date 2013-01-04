clear all; 
close all;

% ------------------ Simulation Configuration  --------------------------------------------------
simulation_start = 0; % 0:= off (when only a new simulation of collision is started), 1:= start simulation(default)
simulation_of_collision = 1; % 0:= off (default), 1:= read from csv-file, 2:= new simulation
packet_delivery_limit = 100;
number_of_simulation = 100;
no_backoff_window_size_max =3000;
no_neighbours_max = 20;
%folder_name = 'messungen/2012-09-08';
%folder_name = 'messungen/2012-12-05';
%folder_name = 'messungen/2012-12-08';
%folder_name = 'messungen/2012-12-12';
folder_name = 'messungen/2012-12-13';
write_simulation_results_2_csv = 0;% 0:= off (default), 1:= write simulation results into csv-file

%----------- Birthday Problem Configuration  -------------------------
%packet_loss_upper_limit = 0.1; %10percent packet loss
vector_packet_loss_upper_limit = [0.1, 0.2, 0.3, 0.4, 0.5];
%----------- Simulation and Birthday Problem Configuration  -------------------------


%----------- General IEEE 802.11 MAC-Layer Configuration  -------------------------
use_ism_bandwith_ghz = 0; % 0:= 2,4 GHz; 1:= 5 GHz; 2:= 2,4 GHz and 5 GHz
number_of_antennas = 1; % Antennas:= Default-Value = 1 for 802.11n there can be more
use_rts_cts = 0  ; % 0:= do not use; 1:=use RTS/CTS (exists at 802.11g and higher)

%----------- IEEE 802.11 MAC-Layer Configuration  -------------------------
is_Address4_requiered = 1; % 1:= yes, else no
use_greenfield = 1; % 0:= off; 1:= on
use_dsss_ofdm = 0; % 0:= off; 1:= on

%----------- IEEE 802.11n MAC-Layer Configuration  -------------------------
use_ieee80211n_mac = 0;% 0:= off (IEEE 802.11 MAC layer is used); 1:= on

use_bandwidth_40_MHz = 0; % 0:= 20 MHz; 1:=40MHz
use_short_guard_interval = 0; % 0:= off, 1:= on 
is_ht_required = 0; % 0:= off, 1:= on 
is_frame_body_8_kb = 0; % 0:= off, 1:= on 
is_a_msdu_used = 0; % 0:= off, 1:= on 
is_a_mpdu_used = 0; % 0:= off, 1:= on 
number_of_msdus_in_a_msdus = 0;
number_of_mpdus_in_a_mpdus = 0;

%------------ Rate Configuration ----------------------------------------
letter_of_standards = {'original','a','b','g','n'};
[ vector_rates_80211 ]  = func_rates_standard_supported(letter_of_standards{1,1});
vector_rates_data = min(vector_rates_80211);
vector_rates_ack = min(vector_rates_80211);
vector_rates_rts = min(vector_rates_80211);%vector_rates_80211a_mandatory;%[1,2];
vector_rates_cts=  min(vector_rates_80211);%vector_rates_80211a_mandatory;%[1,2];

%----------------- MSUD-Size Configuration -------------------------------
vector_msdu_sizes = [0,500,1000,1500,2000,2500,3000,3500,4000, 6000, 8000]; %[Bytes]; size depend from higher layer; assuming a TCP/IP-Layer which limit the payload to 1500; important:"calculate in byte"


%------------------- Backoff with birthday problem   -------------------------------------
%---------------- Birthday-Problem configuration ------------------------
vector_birthday_problem_cw_sizes = 1:1:no_backoff_window_size_max; % Vector for different contention window sizes
vector_birthday_problem_neighbours = 1:1:no_neighbours_max; %vector for different neighbours
matrix_packetloss_neighbours_2_backoff_window_sizes_calc = zeros(size(vector_packet_loss_upper_limit,2),no_neighbours_max);
matrix_packetloss_neighbours_2_backoff_window_sizes_approx = zeros(size(vector_packet_loss_upper_limit,2),no_neighbours_max);
vector_of_successful_conditions = zeros(size(vector_packet_loss_upper_limit,2),1);
for i=1:1:size(vector_packet_loss_upper_limit,2);
    [vector_backoff_window_sizes_per_neighbour,vector_backoff_window_sizes_per_neighbour_approximation, matrix_birthday_problem_collision_likelihood_packet_loss,counter_of_successful_conditions] = func_birthday_problem_calc(vector_birthday_problem_neighbours,vector_birthday_problem_cw_sizes,vector_packet_loss_upper_limit(1,i));
    vector_of_successful_conditions(i,1) = counter_of_successful_conditions;
    for t=1:1:size(vector_birthday_problem_neighbours,2) % Voraussetzung table_backoff_windows und table_neighbours haben die gleiche Anzahl von Elementen
        %if(  table_neighbours(t) ~= 0)
              %matrix_packetloss_neighbours_2_backoff_window_sizes_calc(i,vector_neighbours(t)) = vector_backoff_window_sizes_per_neighbour(t,1);
              %matrix_packetloss_neighbours_2_backoff_window_sizes_approx(i,vector_neighbours(t)) = vector_backoff_window_sizes_per_neighbour_approximation(1,t);
        %end
        matrix_packetloss_neighbours_2_backoff_window_sizes_calc(i,t) = vector_backoff_window_sizes_per_neighbour(t,1);
        matrix_packetloss_neighbours_2_backoff_window_sizes_approx(i,t) = vector_backoff_window_sizes_per_neighbour_approximation(1,t);
       
   end
end
    figure_number = 1;
    test_find_backoff_optimal_on = 0;  
 vector_backoff_window_sizes_standard = func_cw_vector_get(test_find_backoff_optimal_on,letter_of_standards{1,2}, no_backoff_window_size_max,use_greenfield);
%[handler_figure] = func_figure_birthday_problem_neighbours_backoff_window_sizes(figure_number,vector_neighbours, vector_backoff_window_sizes_per_neighbour,vector_backoff_window_sizes_standard);
debug_figures = 0;
if (debug_figures == 1)
[ handler_figure ] = func_figure_backoff_window_sizes_neighbours_different_losses(figure_number,matrix_packetloss_neighbours_2_backoff_window_sizes_calc,vector_packet_loss_upper_limit,vector_of_successful_conditions,vector_backoff_window_sizes_standard);
%figure_number = figure_number + 1;
%[ handler_figure_2 ] = func_figure_backoff_window_sizes_neighbours_different_losses(figure_number,matrix_packetloss_neighbours_2_backoff_window_sizes_approx,vector_packet_loss_upper_limit,vector_of_successful_conditions,vector_backoff_window_sizes_standard);

%[ handler_fig_2 ] = func_figure_backoff_window_sizes_neighbours_different_losses(figure_number,vector_birthday_problem_neighbours,matrix_packetloss_neighbours_2_backoff_window_sizes_approx,packet_loss_upper_limit,vector_of_successful_conditions,vector_backoff_window_sizes_standard);
figure_number = figure_number + 1;
[ handler_figure_3 ] = func_figure_backoff_window_sizes_neighbours_different_losses_2(figure_number,matrix_packetloss_neighbours_2_backoff_window_sizes_calc,matrix_packetloss_neighbours_2_backoff_window_sizes_approx,vector_packet_loss_upper_limit,vector_of_successful_conditions,vector_backoff_window_sizes_standard);
%figure_number = figure_number + 1;
%[hfig_1] = func_figure_birthday_problem_backoff_collision(figure_number,matrix_backoff_windows, likelihood, vector_neighbours, vector_backoff_window_sizes_standard);
%figure_number = figure_number + 1;
%[handler_fig] = func_figure_birthday_problem_neighbours_collision(figure_number,matrix_neighbours, likelihood, vector_backoff_window_sizes, vector_neighbours);
end
 %func_figure_backoff_window_sizes_neighbours_different_losses_2(figure_number,vector_birthday_problem_neighbours,matrix_packetloss_neighbours_2_backoff_window_sizes_calc,matrix_packetloss_neighbours_2_backoff_window_sizes_approx,packet_loss_upper_limit,vector_of_successful_conditions,vector_backoff_window_sizes_standard);
%(figure_number,v_neighbours,matrix_1,matrix_2,vector_packet_loss,vector_of_successful_conditions,vector_backoff_window_sizes_standard)



        
%------------------------contention window params --------------------------------------------------------------------------
test_find_backoff_optimal_on = 2; % 0:= off; 1:= on
%letter_of_standard = letter_of_standards(1,1)
[vector_backoff] = func_cw_vector_get(test_find_backoff_optimal_on,letter_of_standards{1,1}, no_backoff_window_size_max,use_greenfield);
%---------------------------- Simulation ----------------------------------
[matrix_collision,matrix_collision_likelihood,no_neighbours_max,no_backoff_window_size_max, matrix_counter_slots] = func_simulation(simulation_of_collision,vector_backoff,no_neighbours_max,packet_delivery_limit,number_of_simulation,folder_name,write_simulation_results_2_csv);  
%-------------------------------------------------------------------------
%matrix_collision_percent = matrix_collision ./ packet_delivery_limit;
matrix_packetloss_neighbours_2_backoff_window_sizes_sim = zeros(size(vector_packet_loss_upper_limit,2),no_neighbours_max);
for i=1:1:size(vector_packet_loss_upper_limit,2)
    %[vector_backoff_per_neighbour,counter_of_successful_conditions] = func_birthday_problem_search_backoff_neighbours(matrix_collision_percent,vector_packet_loss_upper_limit(1,i));
    [vector_backoff_per_neighbour,counter_of_successful_conditions] = func_birthday_problem_search_backoff_neighbours(matrix_collision_likelihood,vector_packet_loss_upper_limit(1,i));
        for t=1:1:size(vector_birthday_problem_neighbours,2) % Voraussetzung table_backoff_windows und table_neighbours haben die gleiche Anzahl von Elementen
            matrix_packetloss_neighbours_2_backoff_window_sizes_sim(i,t) = vector_backoff_per_neighbour(t,1);
        end
end


debug_sim_fig = 1;
if (debug_sim_fig ==1)
figure_number = figure_number + 1;
% Simulation #Neighbours-Backoff-Window-Sizes for different Packetlosses
[ handler_figure_4 ] = func_figure_simulation_neighbours_backoff_window_size(figure_number,vector_birthday_problem_neighbours,matrix_packetloss_neighbours_2_backoff_window_sizes_sim,vector_packet_loss_upper_limit);
%figure_number = figure_number + 1;
%[ handler_figure_5 ] = func_figure_simulation_neighbours_backoff_window_size(figure_number,vector_birthday_problem_neighbours,matrix_collision_percent,vector_packet_loss_upper_limit);
%[ handler_figure_5 ] = func_figure_simulation_neighbours_backoff_window_size_collision(figure_number,matrix_collision_percent);
%Birthday-Problem 
%Compare Simulation and Calculation
figure_number = figure_number + 1;
vector_neighbours_2 = 1:3:no_neighbours_max; %vector for different neighbours
[matrix_birthday_problem_collision_likelihood_packet_loss_3,matrix_collision_percent_3] = func_birthday_problem_simulation_filter_neighbours(matrix_birthday_problem_collision_likelihood_packet_loss,matrix_collision_likelihood,vector_neighbours_2);
[ handler_figure_6 ] = func_figure_collision_calculation_simulation(figure_number,vector_neighbours_2,matrix_birthday_problem_collision_likelihood_packet_loss_3*100,matrix_collision_percent_3*100);
figure_number = figure_number + 1;
[handler_7] = func_figure_birthday_problem_simulation_comparison(figure_number,vector_birthday_problem_neighbours,matrix_packetloss_neighbours_2_backoff_window_sizes_sim,matrix_packetloss_neighbours_2_backoff_window_sizes_calc);
end

%%TODO
figure_number = figure_number + 1;
matrix_birthday_problem_collision = 100 + (matrix_birthday_problem_collision_likelihood_packet_loss * 100);
func_figure_comparison_2(figure_number,matrix_collision,matrix_birthday_problem_collision)

[handler_figure_1] = func_figure_backoff_collision_mean_std(figure_number,matrix_1,vector_neighbours_filter,vector_backoff_filter,'Anzahl von Kollisionen');
debug_bereinigt = 0;
if (debug_bereinigt == 1)
matrix_collision_percent_2 = zeros(size(matrix_collision_percent));
for i=1:1:size(matrix_collision_percent,1)
    for t=1:1:size(matrix_collision_percent,2)
        if (matrix_collision_percent(i,t) < 1 && matrix_collision_percent(i,t) >= 0)
            matrix_collision_percent_2(i,t) = matrix_collision_percent(i,t) * 100;
        end
    end
end
figure_number = figure_number + 1;
[ handler_figure_6 ] = func_figure_collision_calculation_simulation(figure_number,matrix_birthday_problem_collision_likelihood_packet_loss*100,matrix_collision_percent_2);
end


% ------------------------------ Start calculation ------------------------     
debug_test = 0; 
if (debug_test == 1);
if (simulation_start)
    %------------------ MAC-Layer calculation without msdu_size -------------------
    % MAC-Frame IEEE 802.11 und IEEE 802.11a/b/g
    [frame_mac, frame_rts, frame_cts, frame_ack] = func_ieee_80211_mac(0,is_Address4_requiered);
    %MAC-Frame IEEE 802.11n
    if (use_ieee80211n_mac)
        [frame_mac,output_xml_mac] = func_mac_ieee_80211n(0, is_Address4_requiered, is_ht_required,is_frame_body_8_kb,is_a_msdu_used, number_of_msdus_in_a_msdus, is_a_mpdu_used, number_of_mpdus_in_a_mpdus);
    end
    [matrix_tmt_neighbours,matrix_tmt_backoff,matrix_tmt_collisions,matrix_tmt_collisions_percent,matrix_results_bandwidth_efficient,matrix_tmt_backoff_birthday_problem,matrix_tmt_backoff_birthday_problem_approximation,matrix_duration_delay,output_xml] = func_calculation_rates_msdu_sizes(matrix_collision,no_neighbours_max,no_backoff_window_size_max, matrix_counter_slots,frame_mac, frame_rts, frame_cts, frame_ack,vector_rates_data,vector_rates_ack,vector_rates_rts,vector_rates_cts,vector_msdu_sizes,packet_delivery_limit,packet_loss_upper_limit,use_rts_cts,use_greenfield,use_dsss_ofdm,use_ism_bandwith_ghz,use_bandwidth_40_MHz,number_of_antennas,use_short_guard_interval);
end


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
end

debug_saveas = 0;
if(debug_saveas == 1)
        directory = 'evaluation/';
    [s,mess,messid] = mkdir(directory);
    format ='png';
    filename_1 = sprintf('%sbackoff_neighbours_calc.png',directory);
    filename_2 = sprintf('%sbackoff_neighbours_approx.png',directory);
    filename_3 = sprintf('%sbackoff_neighbours_calc_approx.png',directory);
    
    saveas(handler_figure,filename_1,format)
    saveas(handler_figure_2,filename_2,format)
    saveas(handler_figure_3,filename_3,format)
end