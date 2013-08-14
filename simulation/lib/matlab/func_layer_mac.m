function [matrix_tmt_air_capacity,matrix_tmt_backoff,matrix_tmt_collisions,matrix_tmt_collisions_percent,matrix_results_bandwidth_efficient,matrix_results_collisions_air_capacity_4D,matrix_results_collisions_efficiency_4D,matrix_results_collisions_backoff_4D,output_xml] = func_layer_mac(matrix_number_of_collisions,vector_no_neighbours,vector_contention_window_sizes, matrix_number_of_slots,vector_rates_data,vector_rates_ack,vector_rates_rts,vector_rates_cts,vector_msdu_sizes,matrix_number_of_packets_delivered,vector_layer_mac_configuration,vector_packet_loss_upper_limit)
is_Address4_requiered = vector_layer_mac_configuration(1,1);
use_rts_cts = vector_layer_mac_configuration(1,2);
use_greenfield = vector_layer_mac_configuration(1,3);
use_dsss_ofdm = vector_layer_mac_configuration(1,4);
use_ism_bandwith_ghz = vector_layer_mac_configuration(1,5);
use_bandwidth_40_MHz = vector_layer_mac_configuration(1,6);
number_of_antennas = vector_layer_mac_configuration(1,7);
use_short_guard_interval = vector_layer_mac_configuration(1,8);
is_ht_required = vector_layer_mac_configuration(1,9);
is_frame_body_8_kb = vector_layer_mac_configuration(1,10);
is_a_msdu_used = vector_layer_mac_configuration(1,11);
number_of_msdus_in_a_msdus= vector_layer_mac_configuration(1,12);
is_a_mpdu_used = vector_layer_mac_configuration(1,13);
number_of_mpdus_in_a_mpdus = vector_layer_mac_configuration(1,14);
use_ieee80211n_mac = vector_layer_mac_configuration(1,15);
%% Initialization
    matrix_tmt_air_capacity = zeros(size(vector_rates_data,2),size(vector_msdu_sizes,2),size(vector_no_neighbours,2));
    matrix_tmt_backoff = zeros(size(vector_rates_data,2),size(vector_msdu_sizes,2),size(vector_no_neighbours,2));
    matrix_tmt_collisions = zeros(size(vector_rates_data,2),size(vector_msdu_sizes,2),size(vector_no_neighbours,2));
    matrix_tmt_collisions_percent = zeros(size(vector_rates_data,2),size(vector_msdu_sizes,2),size(vector_no_neighbours,2));
    matrix_results_bandwidth_efficient = zeros(size(vector_rates_data,2),size(vector_msdu_sizes,2),size(vector_no_neighbours,2));
    matrix_results_collisions_air_capacity_4D =  zeros(size(vector_rates_data,2),size(vector_msdu_sizes,2),size(vector_no_neighbours,2),size(vector_packet_loss_upper_limit,2));
    matrix_results_collisions_efficiency_4D =  zeros(size(vector_rates_data,2),size(vector_msdu_sizes,2),size(vector_no_neighbours,2),size(vector_packet_loss_upper_limit,2));
    matrix_results_collisions_backoff_4D =  zeros(size(vector_rates_data,2),size(vector_msdu_sizes,2),size(vector_no_neighbours,2),size(vector_packet_loss_upper_limit,2));
    %matrix_tmt_backoff_birthday_problem = zeros(size(vector_rates_data,2),size(vector_msdu_sizes,2),size(vector_no_neighbours,2));
    %matrix_tmt_backoff_birthday_problem_approximation = zeros(size(vector_rates_data,2),size(vector_msdu_sizes,2),size(vector_no_neighbours,2));
    %% Calculation of Bandwith (2.4 GHz, 5 GHz or both)
    is_ism_5_ghz = 0;
    is_ism_2_4_and_5_ghz = 0;
    if (use_ism_bandwith_ghz == 1)
        is_ism_5_ghz = 1;
    elseif (use_ism_bandwith_ghz == 2)
        is_ism_2_4_and_5_ghz = 1;
    else
        is_ism_2_4_ghz = 1;
    end
    output_xml = '';
    %% Throughput calculation starts here
    for index_rates=1:1:size(vector_rates_data,2)
        for index_msdu=1:1:size(vector_msdu_sizes,2)
    %% ------------------ MAC-Layer calculation: overhead and msdu_size [bits]  -------------------
            % MAC-Frame IEEE 802.11 und IEEE 802.11a/b/g
            [frame_mac, frame_rts, frame_cts, frame_ack] = func_ieee_80211_mac(vector_msdu_sizes(1,index_msdu),is_Address4_requiered);
            %MAC-Frame IEEE 802.11n
            if (use_ieee80211n_mac)
                [frame_mac,output_xml_mac] = func_mac_ieee_80211n(vector_msdu_sizes(1,index_msdu), is_Address4_requiered, is_ht_required,is_frame_body_8_kb,is_a_msdu_used, number_of_msdus_in_a_msdus, is_a_mpdu_used, number_of_mpdus_in_a_mpdus);
                output_xml = output_xml_mac;
            end
   %% Calculate for each rate and msdu-size the phy-layer duration for each MAC-Packet
            % Different physical layers IEEE 802.11 and IEEE 802.11a/b/g/n
            [duration_plcp_framing_mac, time_sifs, time_difs, time_slot, output_xml_frame_mac ] = func_layer_phy(vector_rates_data(1,index_rates), frame_mac, is_ism_2_4_ghz, is_ism_5_ghz, is_ism_2_4_and_5_ghz, use_greenfield, use_dsss_ofdm, use_short_guard_interval, use_bandwidth_40_MHz, number_of_antennas);
            [duration_plcp_framing_ack] = func_layer_phy(vector_rates_ack(1,1), frame_ack, is_ism_2_4_ghz, is_ism_5_ghz, is_ism_2_4_and_5_ghz,use_greenfield,use_dsss_ofdm,use_short_guard_interval,use_bandwidth_40_MHz,number_of_antennas);
            [duration_plcp_framing_rts] = func_layer_phy(vector_rates_rts(1,1), frame_rts, is_ism_2_4_ghz, is_ism_5_ghz, is_ism_2_4_and_5_ghz,use_greenfield,use_dsss_ofdm,use_short_guard_interval, use_bandwidth_40_MHz,number_of_antennas);
            [duration_plcp_framing_cts] = func_layer_phy( vector_rates_cts(1,1), frame_cts, is_ism_2_4_ghz, is_ism_5_ghz, is_ism_2_4_and_5_ghz,use_greenfield,use_dsss_ofdm,use_short_guard_interval, use_bandwidth_40_MHz,number_of_antennas);
            output_xml = sprintf('%s%s',output_xml_frame_mac,output_xml);
   %% Calculate for each rate and msdu-size the physical layer duration for each MAC-Packet               
                delay_per_msdu_broadcast = time_difs + duration_plcp_framing_mac;%[sec]; case: collision: without ack-frame
                delay_per_msdu_unicast_successful = delay_per_msdu_broadcast +  time_sifs  + duration_plcp_framing_ack; %   + plcp_framing_ack_duration;%[sec]; case: successful transmission
                delay_per_msdu_unicast_unsuccessful = delay_per_msdu_unicast_successful - duration_plcp_framing_ack;               
                if (use_rts_cts == 1)
                    overhead_rts_cts = duration_plcp_framing_rts + time_sifs + duration_plcp_framing_cts + time_sifs;
                    delay_per_msdu_unicast_successful = delay_per_msdu_unicast_successful + overhead_rts_cts;%[sec]; case: successful transmission            
                    delay_per_msdu_unicast_unsuccessful = time_difs + duration_plcp_framing_rts + time_sifs;
                end          
                [vector_tmt_air_capacity_max, vector_tmt_index_backoff_max, vector_number_of_collisions,vector_efficiency_for_tmt,matrix_collisions_backoff,matrix_collisions_air_capacity,matrix_collisions_efficiency] = func_throughput_efficiency_for_data_rate_packet_size(matrix_number_of_slots, matrix_number_of_collisions, vector_rates_data(1,index_rates),matrix_number_of_packets_delivered,vector_msdu_sizes(1,index_msdu),delay_per_msdu_unicast_successful, delay_per_msdu_unicast_unsuccessful, time_slot,vector_packet_loss_upper_limit);
                % In 3 dimensionale Matrizen einordnen und noch ein paar Rechnungen
                %[ vector_tmt_max_per_neighbour, vector_number_of_collisions,vector_efficiency_for_tmt_max_per_neighbour,vector_birthday_problem_collision_likelihood ] = func_throughput_efficiency_for_data_rate_packet_size(rate_data,packet_delivery_limit,msdu_size,delay_per_msdu_without_ack, delay_per_msdu_with_ack, time_slot, matrix_counter_slots, matrix_collision,matrix_birthday_problem_collision_likelihood_packet_loss  );
                for n=1:1:size(vector_no_neighbours,2)
                    matrix_tmt_air_capacity(index_rates,index_msdu,n) = vector_tmt_air_capacity_max(n,1);
                    if (vector_tmt_index_backoff_max(n,1) > 0)
                        matrix_tmt_backoff(index_rates,index_msdu,n) = vector_contention_window_sizes(1,vector_tmt_index_backoff_max(n,1));
                    end
                    matrix_tmt_collisions(index_rates,index_msdu,n) = vector_number_of_collisions(n,1);
                    if ((vector_number_of_collisions(n,1) + 100) > 0)
                        matrix_tmt_collisions_percent(index_rates,index_msdu,n) = (vector_number_of_collisions(n,1) / (vector_number_of_collisions(n,1) + 100)); %ratio [dezimal]
                    end
                    matrix_results_bandwidth_efficient(index_rates,index_msdu,n) = vector_efficiency_for_tmt(n,1) * 100;
                    %matrix_tmt_backoff_birthday_problem(index_rates,index_msdu,n) = vector_birthday_problem_collision_likelihood(n,1) * 100; %[percent]
                    %matrix_tmt_backoff_birthday_problem_approximation(index_rates,index_msdu,n) = func_backkoff_approximation(matrix_tmt_collisions_percent(index_rates,index_msdu,n),n);
                    matrix_tmt_collisions_percent(index_rates,index_msdu,n) = matrix_tmt_collisions_percent(index_rates,index_msdu,n) * 100; %[percent]                   
                end
                % In 4 dimensionale Matrix einordnen
                for n=1:1:size(vector_no_neighbours,2)
                    for p=1:1:size(vector_packet_loss_upper_limit,2)
                    matrix_results_collisions_backoff_4D(index_rates,index_msdu,n,p) = matrix_collisions_backoff(n,p);
                    matrix_results_collisions_air_capacity_4D(index_rates,index_msdu,n,p) = matrix_collisions_air_capacity(n,p);
                    matrix_results_collisions_efficiency_4D(index_rates,index_msdu,n,p) = matrix_collisions_efficiency(n,p);
                        
                    end
                end               
        end
    end
end


