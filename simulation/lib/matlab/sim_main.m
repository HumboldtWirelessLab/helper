clear all; 
close all;

is_Address4_requiered = 1; % 1:= yes, else no
greenfield_use = 1; % 0:= off; 1:= on
greenfield_use_80211b = 1; % 0:= off; 1:= on
dsss_ofdm_use = 0; % 0:= off; 1:= on
packet_delivery_limit = 100;

 no_neighbours_max = 0 ; % Initialisierung
 no_backoff_window_size_max =0;%Initialisierung


is_ism_2_4_ghz = 1; % 0:= off; 1:= on % only 802.11 and extentions 802.11b/g
is_ism_5_ghz = 0; % 0:= off; 1:= on % only 802.11a
is_ism_2_4_and_5_ghz = 0; % 0:= off; 1:= on % only 802.11n

bandwidth = 0; % used for 802.11n as follows: 0:= 20 MHz; 1:=40MHz
mcs = 1; % used for 802.11n as follows:mcs;  mcs index number is mapped to the data rate
rts_cts_on = 0  ; % 0:= do not use; 1:=use RTS/CTS (exists at 802.11g and higher)

%---------------------- 802.11n Parameter --------------------------------
short_guard_interval = 0; % 0:= off, 1:= on for use
is_ht_required = 0; % 0:= off, 1:= on for use
is_frame_body_8_kb = 0; % 0:= off, 1:= on for use
is_a_msdu_used = 0; % 0:= off, 1:= on for use
is_a_mpdu_used = 0; % 0:= off, 1:= on for use
number_of_msdus_in_a_msdus = 0;
number_of_mpdus_in_a_mpdus = 0;

%------------ Support rates for each Standard ----------------------------------------
vector_rates_80211 = [1,2];
vector_rates_80211b_hr_dsss = [5.5,11];
vector_rates_80211b = [vector_rates_80211,vector_rates_80211b_hr_dsss];
vector_rates_80211a_mandatory = [6,12,24];
vector_rates_80211a_optional = [9,18,36,48,54,72];
vector_rates_80211a = sort([vector_rates_80211a_mandatory,vector_rates_80211a_optional]);
vector_rates_80211g_erp_pbcc = [22,33];
vector_rates_80211g_erp_ofdm = vector_rates_80211a;
vector_rates_80211g = sort([vector_rates_80211,vector_rates_80211b_hr_dsss,vector_rates_80211g_erp_pbcc, vector_rates_80211g_erp_ofdm]);
%vector_rates_80211g = sort([6,12,18,24,36,48,54]);
%------------ Rate Configuration ----------------------------------------
vector_rates= sort([6,11,12,24,36,48,54]); %vector_rates_80211g; %vector_rates_80211a_mandatory;%vector_rates_80211; % vector_rates_80211a;
vector_rates_ack = min(vector_rates_80211);
vector_rates_rts = min(vector_rates_80211);%vector_rates_80211a_mandatory;%[1,2];
vector_rates_cts=  min(vector_rates_80211);%vector_rates_80211a_mandatory;%[1,2];
%vector_rate_min_for_efficiency_calc = 20;
%----------------- MSUD-Size Configuration -------------------------------
vector_msdu = [0,500,1000,1500,2000,2500,3000,3500,4000]; %[Bytes]; size depend from higher layer; assuming a TCP/IP-Layer which limit the payload to 1500; important:"calculate in byte"
%------------------------Contention Window Params --------------------------------------------------------------------------
%[vector_backoff] = func_cw_vector_get(test_find_backoff_optimal_on, no_backoff_window_size_max);
% ------------------ Simulation Configuration  --------------------------------------------------
simulation_of_collision = 1; % 0:= off (default), 1:= read from csv-file, 2:= new simulation
write_simulation_results_2_csv = 0;% 0:= off (default), 1:= write simulation results into csv-file
simulation_start = 1; % 0:= off (when only a new simulation of collision is started), 1:= start simulation(default)
% Collisions were simulated with different seeds for 1000 retries and 100
% stations, so you can use the csv-data
if (simulation_of_collision == 0)
    number_of_neighbours = 1;
    backoff_window_size_max = 1;
    matrix_counter_slots = zeros(number_of_neighbours,backoff_window_size_max);
    matrix_collision = zeros(number_of_neighbours,backoff_window_size_max);
elseif (simulation_of_collision == 1)
    %folder_data_measurement = sprintf('messungen/2012-07-27');
    folder_data_measurement = sprintf('messungen/2012-09-08');
    sim_data_collision = sprintf('%s/sim_collision_avg.csv',folder_data_measurement);
    sim_data_counter_slots = sprintf('%s/sim_counter_slots_global.csv',folder_data_measurement);
     
    matrix_collision = csvread(sim_data_collision);
    matrix_counter_slots = csvread(sim_data_counter_slots);
    [no_neighbours_max,no_backoff_window_size_max] = size(matrix_collision);
elseif (simulation_of_collision == 2)
    no_neighbours_max = 10 ;
    number_of_simulation = 1000;
    no_backoff_window_size_max =3000;
    %------------------------Contention Window Params --------------------------------------------------------------------------
    test_find_backoff_optimal_on = 2; % 0:= off; 1:= on
    [vector_backoff] = func_cw_vector_get(test_find_backoff_optimal_on, no_backoff_window_size_max);

    %[matrix_results_packets_delivery_counter_global,matrix_results_counter_slots_global,matrix_collision] = func_simulation_start(number_of_simulation,vector_backoff,no_neighbours_max,packet_delivery_limit);
    [matrix_results_packets_delivery_counter_global,matrix_results_counter_slots_global,matrix_results_collision_avg,matrix_results_collision_min,matrix_results_collision_min_counter,matrix_results_collision_max,matrix_results_collision_max_counter,matrix_results_retries_avg,matrix_results_retries_min,matrix_results_retries_min_counter,matrix_results_retries_max,matrix_results_retries_max_counter] = func_simulation_start(number_of_simulation,vector_backoff,no_neighbours_max,packet_delivery_limit );
    if (write_simulation_results_2_csv == 1)
        func_write_csv_stats(matrix_results_packets_delivery_counter_global,matrix_results_counter_slots_global,matrix_results_collision_avg,matrix_results_collision_min,matrix_results_collision_min_counter,matrix_results_collision_max,matrix_results_collision_max_counter,matrix_results_retries_avg,matrix_results_retries_min,matrix_results_retries_min_counter,matrix_results_retries_max,matrix_results_retries_max_counter)
    end
end
if (simulation_start)
    % Birthday-Problem calculation
    vector_cw_birthday_problem = 2:1:no_backoff_window_size_max+1;
    vector_birthday_problem_neighbours = 1:1:no_neighbours_max;
    [matrix_birthday_problem_collision_likelihood_packet_loss] = func_birhtday_problem_packetloss(vector_birthday_problem_neighbours,vector_cw_birthday_problem);
    %matrix_birthday_problem_collision_likelihood = matrix_birthday_problem_collision_likelihood';
    %matrix_tmt_msdu =zeros(size(vector_rates,2),size(vector_msdu,2));
    matrix_tmt_neighbours = zeros(size(vector_rates,2),size(vector_msdu,2),no_neighbours_max);
    matrix_tmt_backoff = zeros(size(vector_rates,2),size(vector_msdu,2),no_neighbours_max);
    matrix_tmt_collisions = zeros(size(vector_rates,2),size(vector_msdu,2),no_neighbours_max);
    matrix_tmt_collisions_percent = zeros(size(vector_rates,2),size(vector_msdu,2),no_neighbours_max);
    matrix_results_bandwidth_efficient = zeros(size(vector_rates,2),size(vector_msdu,2),no_neighbours_max);
    matrix_tmt_backoff_birthday_problem = zeros(size(vector_rates,2),size(vector_msdu,2),no_neighbours_max);
    matrix_tmt_backoff_birthday_problem_approximation = zeros(size(vector_rates,2),size(vector_msdu,2),no_neighbours_max);
    sifs_time = 0;
    difs_time = 0;
    slot_time = 0;
    
    counter_slots_global = 0;
    counter_collision_global = 0;
    packets_delivery_counter_global = 100;
    byte = 8; %[bit]
    kb = 1000;%[byte]   
    Mb = kb * 1000;%[byte]
    plcp_framing_mac_duration = 0;
    for index_rates=1:1:size(vector_rates,2)
        for index_msdu=1:1:size(vector_msdu,2)
            [mac_frame, rts_frame, cts_frame, ack_frame] = func_ieee_80211_mac(vector_msdu(1,index_msdu),is_Address4_requiered);
            %--------------------------- IEEE 802.11 - DSSS -----------------------------------
            %if ((~isempty(find(vector_rates_80211 == vector_rates(1,index_rates), 1))) && greenfield_use == 0 && is_ism_2_4_ghz == 1)
            %if ((~isempty(find(vector_rates_80211 == vector_rates(1,index_rates), 1))) && greenfield_use == 0 && use_802_11 == 1)
            if ((~isempty(find(vector_rates_80211 == vector_rates(1,index_rates), 1)))  && greenfield_use == 0 && is_ism_2_4_ghz == 1) % && use_802_11 == 1)
                [sifs_time, difs_time, slot_time] = func_phy_ieee80211_get_sifs_difs();
                [ vector_cw ] =  func_ieee80211_contention_window_get();
                [plcp_framing_mac_bits,plcp_framing_mac_duration, output_xml_mac] = func_phy_ieee80211(vector_rates(1,index_rates),mac_frame);
                [plcp_framing_ack_bits,plcp_framing_ack_duration, output_xml_ack] = func_phy_ieee80211(vector_rates_ack(1,1),ack_frame);
                [plcp_framing_bits_rts,plcp_framing_duration_rts, output_xml_rts] = func_phy_ieee80211(vector_rates_rts(1,1),rts_frame);
                [plcp_framing_bits_cts,plcp_framing_duration_cts, output_xml_cts] = func_phy_ieee80211(vector_rates_cts(1,1),cts_frame);
            %--------------------------- IEEE 802.11b - HRDSSS -----------------------------------
            %elseif ((~isempty(find(vector_rates_80211b == vector_rates(1,index_rates), 1))) && is_ism_2_4_ghz == 1)
            elseif ((~isempty(find(vector_rates_80211b == vector_rates(1,index_rates), 1))) && is_ism_2_4_ghz == 1)
                [sifs_time, difs_time,slot_time ] = func_phy_ieee80211b_get_sifs_difs_2();
                [ vector_cw ] =  func_ieee80211b_contention_window_get();
                [plcp_framing_mac_bits,plcp_framing_mac_duration, output_xml_mac] = func_phy_ieee80211b_2(vector_rates(1,index_rates),mac_frame,greenfield_use_80211b);
                [plcp_framing_ack_bits,plcp_framing_ack_duration, output_xml_ack] = func_phy_ieee80211b_2(vector_rates_ack(1,1),ack_frame,greenfield_use_80211b);
                [plcp_framing_bits_rts,plcp_framing_duration_rts, output_xml_rts] = func_phy_ieee80211b_2(vector_rates_rts(1,1),rts_frame,greenfield_use_80211b);
                [plcp_framing_bits_cts,plcp_framing_duration_cts, output_xml_cts] = func_phy_ieee80211b_2(vector_rates_cts(1,1),cts_frame,greenfield_use_80211b);
            %--------------------------- IEEE 802.11a - OFDM -----------------------------------
            %elseif ((~isempty(find(vector_rates_80211a == vector_rates(1,index_rates), 1))) && is_ism_5_ghz == 1)
            elseif ((~isempty(find(vector_rates_80211a == vector_rates(1,index_rates), 1))) && is_ism_5_ghz == 1)
                [sifs_time, difs_time,slot_time ] = func_phy_ieee80211a_get_sifs_difs_2();
                [ vector_cw ] =  func_ieee80211a_contention_window_get();
                [plcp_framing_mac_bits,plcp_framing_mac_duration, output_xml_mac] = func_phy_ieee80211a_2(vector_rates(1,index_rates),mac_frame);
                [plcp_framing_ack_bits,plcp_framing_ack_duration, output_xml_ack] = func_phy_ieee80211a_2(vector_rates_ack(1,1),ack_frame);
                [plcp_framing_bits_rts,plcp_framing_duration_rts, output_xml_rts] = func_phy_ieee80211a_2(vector_rates_rts(1,1),rts_frame);
                [plcp_framing_bits_cts,plcp_framing_duration_cts, output_xml_cts] = func_phy_ieee80211a_2(vector_rates_cts(1,1),cts_frame);
            %--------------------------- IEEE 802.11g - OFDM %----------------------------------- 
            %elseif ((~isempty(find(vector_rates_80211g == vector_rates(1,index_rates), 1))) && is_ism_2_4_ghz == 1)
            elseif ((~isempty(find(vector_rates_80211g == vector_rates(1,index_rates), 1))) && is_ism_2_4_ghz == 1)
                [sifs_time, difs_time,slot_time ] = func_phy_ieee80211g_get_sifs_difs_2(greenfield_use); % If the network consists only of 802.11g stations, the slot time may be shortened from the 802.11b-compatible value to the shorter value used in 802.11a.; see Gast,2005,ERP Physical Medium Dependent (PMD) Layer; Characteristics of the ERP PHY
                [ vector_cw ] =  func_ieee80211g_contention_window_get(greenfield_use);
                [plcp_framing_mac_bits,plcp_framing_mac_duration, output_xml_mac] = func_phy_ieee80211g_2(vector_rates(1,index_rates),mac_frame,greenfield_use, dsss_ofdm_use);
                [plcp_framing_ack_bits,plcp_framing_ack_duration, output_xml_ack] = func_phy_ieee80211g_2(vector_rates_ack(1,1),ack_frame,greenfield_use, dsss_ofdm_use);
                [plcp_framing_bits_rts,plcp_framing_duration_rts, output_xml_rts] = func_phy_ieee80211g_2(vector_rates_rts(1,1),rts_frame,greenfield_use, dsss_ofdm_use);
                [plcp_framing_bits_cts,plcp_framing_duration_cts, output_xml_cts] = func_phy_ieee80211g_2(vector_rates_cts(1,1),cts_frame,greenfield_use, dsss_ofdm_use);
            %--------------------------- IEEE 802.11n - OFDM -----------------------------------
            %elseif ((~isempty(find(vector_rates_80211g == vector_rates(1,index_rates), 1))) && is_ism_2_4_and_5_ghz == 1)
            elseif ((~isempty(find(vector_rates_80211n == vector_rates(1,index_rates), 1))) && is_ism_2_4_and_5_ghz == 1)
                [sifs_time, difs_time,slot_time ] = func_phy_ieee80211n_get_sifs_difs_2();
                [ vector_cw ] =  func_ieee80211n_contention_window_get();
                [mac_frame,output_xml] = func_mac_ieee_80211n(vector_msdu(1,index_msdu), is_Address4_requiered, is_ht_required,is_frame_body_8_kb,is_a_msdu_used, number_of_msdus_in_a_msdus, is_a_mpdu_used, number_of_mpdus_in_a_mpdus);
                [plcp_framing_mac_bits,plcp_framing_mac_duration, output_xml_mac] = func_phy_ieee80211n_2(mcs,mac_frame,short_guard_interval, bandwidth,greenfield );
                [plcp_framing_ack_bits,plcp_framing_ack_duration, output_xml_ack] = func_phy_ieee80211n_2(mcs,ack_frame,short_guard_interval, bandwidth,greenfield );
                [plcp_framing_bits_rts,plcp_framing_duration_rts, output_xml_rts] = func_phy_ieee80211n_2(vector_rates_rts(1,1),rts_frame,greenfield_use, dsss_ofdm_use);
                [plcp_framing_bits_cts,plcp_framing_duration_cts, output_xml_cts] = func_phy_ieee80211n_2(vector_rates_cts(1,1),cts_frame,greenfield_use, dsss_ofdm_use);
            else
                difs_time = 0;
                plcp_framing_mac_duration = 0;
                sifs_time = 0;
                plcp_framing_ack_duration = 0;
                plcp_framing_duration_rts = 0;
                plcp_framing_duration_cts = 0;
            end
            if (plcp_framing_mac_duration ~= 0)
                time_to_wait_for_ack = sifs_time  + plcp_framing_ack_duration;
                delay_per_msdu_without_ack = difs_time + plcp_framing_mac_duration +  time_to_wait_for_ack;%[sec]; case: collision: without ack-frame
                delay_per_msdu_with_ack = delay_per_msdu_without_ack; %   + plcp_framing_ack_duration;%[sec]; case: successful transmission
                if (rts_cts_on == 1)
                    time_to_wait_for_cts = sifs_time + plcp_framing_duration_cts;
                    delay_per_msdu_without_ack = difs_time + plcp_framing_duration_rts + time_to_wait_for_cts ;%[sec]; case: collision: without ack-frame
                    delay_per_msdu_with_ack = delay_per_msdu_without_ack + sifs_time +  plcp_framing_mac_duration + time_to_wait_for_ack;%[sec]; case: successful transmission            
                end
            else
                delay_per_msdu_without_ack = 0;
                delay_per_msdu_with_ack = 0;
            end
            if (simulation_of_collision == 0)
                for n=1:1:number_of_neighbours
                    for k=1:1:backoff_window_size_max
                        matrix_counter_slots(n,k) = min(vector_cw) / 2;               
                    end
                end
            end
            % Berechnung des Durchsatzes und der Effizienz für eine
            % bestimmte Datenrate und eine bestimmte Paketgröße
            %    matrix_air_capacity =
            %    zeros(number_of_neighbours,backoff_window_size_max); für
            %    eine bestimmte Anzahl von Nachbarn und
            %    Backoff-Fenstergröße
            %   matrix_efficiency = zeros(number_of_neighbours,backoff_window_size_max);
            if (delay_per_msdu_without_ack ~= 0 && delay_per_msdu_with_ack ~= 0)
                % matrix_air_capacity   [Mbps]
                % matrix_efficiency     [percent]
                [matrix_air_capacity, matrix_efficiency ] = func_calculation_air_capacity_efficiency(vector_rates(1,index_rates),packet_delivery_limit,vector_msdu(1,index_msdu),delay_per_msdu_without_ack, delay_per_msdu_with_ack, slot_time, matrix_counter_slots, matrix_collision);
                [ vector_tmt_max_per_neighbour, vector_backoff_window_size_for_tmt_max_per_neighbour ] = func_find_throughput_highest(matrix_air_capacity);
                vector_number_of_collisions = func_find_for_throughput_highest(matrix_collision, vector_backoff_window_size_for_tmt_max_per_neighbour);
                vector_efficiency_for_tmt_max_per_neighbour = func_find_for_throughput_highest(matrix_efficiency, vector_backoff_window_size_for_tmt_max_per_neighbour);
                vector_birthday_problem_collision_likelihood = func_find_for_throughput_highest_2(matrix_birthday_problem_collision_likelihood_packet_loss, vector_backoff_window_size_for_tmt_max_per_neighbour);
                %vector_birthday_problem_collision_likelihood = func_test_birthday_problem_2(vector_backoff_window_size_for_tmt_max_per_neighbour, size(vector_backoff_window_size_for_tmt_max_per_neighbour,1));
                % Save [ vector_rate_current_tmt_max_per_neighbour, vector_rate_current_tmt_max_backoff_window_size ] for later use 
                %m_helper =  vector_number_of_collisions ./ (vector_number_of_collisions + 100);
                for n=1:1:size(vector_tmt_max_per_neighbour,1)
                    matrix_tmt_neighbours(index_rates,index_msdu,n) = vector_tmt_max_per_neighbour(n,1);
                    matrix_tmt_backoff(index_rates,index_msdu,n) =  vector_backoff_window_size_for_tmt_max_per_neighbour(n,1);
                    matrix_tmt_collisions(index_rates,index_msdu,n) = vector_number_of_collisions(n,1);
                    matrix_tmt_collisions_percent(index_rates,index_msdu,n) = (vector_number_of_collisions(n,1) / (vector_number_of_collisions(n,1) + 100)); %ratio [dezimal]
                    matrix_results_bandwidth_efficient(index_rates,index_msdu,n) = vector_efficiency_for_tmt_max_per_neighbour(n,1);
                    matrix_tmt_backoff_birthday_problem(index_rates,index_msdu,n) = vector_birthday_problem_collision_likelihood(n,1) * 100; %[percent]
                    matrix_tmt_backoff_birthday_problem_approximation(index_rates,index_msdu,n) = func_backkoff_approximation(matrix_tmt_collisions_percent(index_rates,index_msdu,n),n);
                    matrix_tmt_collisions_percent(index_rates,index_msdu,n) = matrix_tmt_collisions_percent(index_rates,index_msdu,n) * 100; %[percent]
                end
            else
                for n=1:1:no_neighbours_max
                    matrix_tmt_neighbours(index_rates,index_msdu,n) = 0;
                    matrix_tmt_backoff(index_rates,index_msdu,n) =  0;
                    matrix_tmt_collisions(index_rates,index_msdu,n) = 0;
                    matrix_results_bandwidth_efficient(index_rates,index_msdu,n) = 0;
                    matrix_tmt_backoff_birthday_problem(index_rates,index_msdu,n) = 0;
                    matrix_tmt_backoff_birthday_problem_approximation(index_rates,index_msdu,n) = 0;
                end
            end
        end
    end
    func_sim_evaluation(vector_rates,vector_msdu,matrix_tmt_neighbours,matrix_tmt_backoff,matrix_tmt_collisions,matrix_tmt_collisions_percent,matrix_results_bandwidth_efficient,matrix_tmt_backoff_birthday_problem,matrix_collision,matrix_birthday_problem_collision_likelihood_packet_loss,matrix_tmt_backoff_birthday_problem_approximation);
end