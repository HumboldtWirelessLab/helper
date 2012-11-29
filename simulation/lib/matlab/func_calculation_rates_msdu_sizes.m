%function [matrix_tmt_neighbours,matrix_tmt_backoff,matrix_tmt_collisions,matrix_tmt_collisions_percent,matrix_results_bandwidth_efficient,matrix_tmt_backoff_birthday_problem,matrix_tmt_backoff_birthday_problem_approximation,matrix_duration_delay,output_xml] = func_calculation_rates_msdu_sizes(frame_mac,vector_rates,vector_rates_ack,vector_rates_rts,vector_rates_cts,vector_msdu_sizes,packet_delivery_limit,packet_loss_upper_limit,no_neighbours_max,rts_cts_on,use_greenfield,use_dsss_ofdm,is_ism_2_4_ghz,use_bandwidth_40MHz,number_of_antennas,use_short_guard_interval)
%function[matrix_tmt_neighbours,matrix_tmt_backoff,matrix_tmt_collisions,matrix_tmt_collisions_percent,matrix_results_bandwidth_efficient,matrix_tmt_backoff_birthday_problem,matrix_tmt_backoff_birthday_problem_approximation,matrix_duration_delay,output_xml] = func_calculation_rates_msdu_sizes(frame_mac, frame_rts, frame_cts, frame_ack,vector_rates_data,vector_rates_ack,vector_rates_rts,vector_rates_cts,vector_msdu_sizes,packet_delivery_limit,packet_loss_upper_limit,use_rts_cts,use_greenfield,use_dsss_ofdm,use_ism_bandwith_ghz,use_bandwidth_40_MHz,number_of_antennas,use_short_guard_interval)
 function [matrix_tmt_neighbours,matrix_tmt_backoff,matrix_tmt_collisions,matrix_tmt_collisions_percent,matrix_results_bandwidth_efficient,matrix_tmt_backoff_birthday_problem,matrix_tmt_backoff_birthday_problem_approximation,matrix_duration_delay,output_xml] = func_calculation_rates_msdu_sizes(matrix_collision,no_neighbours_max,no_backoff_window_size_max, matrix_counter_slots,frame_mac, frame_rts, frame_cts, frame_ack,vector_rates_data,vector_rates_ack,vector_rates_rts,vector_rates_cts,vector_msdu_sizes,packet_delivery_limit,packet_loss_upper_limit,use_rts_cts,use_greenfield,use_dsss_ofdm,use_ism_bandwith_ghz,use_bandwidth_40_MHz,number_of_antennas,use_short_guard_interval);

    %matrix_birthday_problem_collision_likelihood = matrix_birthday_problem_collision_likelihood';
    %matrix_tmt_msdu =zeros(size(vector_rates,2),size(vector_msdu,2));
    matrix_tmt_neighbours = zeros(size(vector_rates,2),size(vector_msdu_sizes,2),no_neighbours_max);
    matrix_tmt_backoff = zeros(size(vector_rates,2),size(vector_msdu_sizes,2),no_neighbours_max);
    matrix_tmt_collisions = zeros(size(vector_rates,2),size(vector_msdu_sizes,2),no_neighbours_max);
    matrix_tmt_collisions_percent = zeros(size(vector_rates,2),size(vector_msdu_sizes,2),no_neighbours_max);
    matrix_results_bandwidth_efficient = zeros(size(vector_rates,2),size(vector_msdu_sizes,2),no_neighbours_max);
    matrix_tmt_backoff_birthday_problem = zeros(size(vector_rates,2),size(vector_msdu_sizes,2),no_neighbours_max);
    matrix_tmt_backoff_birthday_problem_approximation = zeros(size(vector_rates,2),size(vector_msdu_sizes,2),no_neighbours_max);
    matrix_duration_delay = zeros(size(vector_rates,2),size(vector_msdu_sizes,2));
    %time_sifs = 0;
    %time_difs = 0;
    %time_slot = 0;
    
    %counter_slots_global = 0;
    %counter_collision_global = 0;
    %packets_delivery_counter_global = 100;
    %byte = 8; %[bit]
    %kb = 1000;%[byte]   
    %Mb = kb * 1000;%[byte]
    %plcp_framing_duration_mac = 0;
    is_ism_5_ghz = 0;
    is_ism_2_4_and_5_ghz = 0;
    if (use_ism_bandwith_ghz == 1)
        is_ism_5_ghz = 1;
    elseif (use_ism_bandwith_ghz == 2)
        is_ism_2_4_and_5_ghz = 1;
    else
        is_ism_2_4_ghz = 1;
    end

    for index_rates=1:1:size(vector_rates_data,2)
        for index_msdu=1:1:size(vector_msdu_sizes,2)
vector_msdu(1,index_msdu)
            % Different physical layers IEEE 802.11 and IEEE 802.11a/b/g/n
            
            [plcp_framing_duration_mac,time_sifs, time_difs, time_slot, output_xml_frame_mac] = func_layer_phy( vector_rates_data(1,index_rates), frame_mac, is_ism_2_4_ghz, is_ism_5_ghz, is_ism_2_4_and_5_ghz,use_greenfield,use_dsss_ofdm,use_short_guard_interval, bandwidth,number_of_antennas);             
            [plcp_framing_duration_ack] = func_layer_phy(vector_rates_ack, frame_ack, is_ism_2_4_ghz, is_ism_5_ghz, is_ism_2_4_and_5_ghz,use_greenfield,use_dsss_ofdm,use_short_guard_interval,use_bandwidth_40_MHz,number_of_antennas);
            [plcp_framing_duration_rts] = func_layer_phy(vector_rates_rts, frame_rts, is_ism_2_4_ghz, is_ism_5_ghz, is_ism_2_4_and_5_ghz,use_greenfield,use_dsss_ofdm,use_short_guard_interval, use_bandwidth_40_MHz,number_of_antennas);
            [plcp_framing_duration_cts] = func_layer_phy( vector_rates_cts, frame_cts, is_ism_2_4_ghz, is_ism_5_ghz, is_ism_2_4_and_5_ghz,use_greenfield,use_dsss_ofdm,use_short_guard_interval, use_bandwidth_40_MHz,number_of_antennas);
            output_xml = sprintf('%s%s',output_xml_frame_mac,output_xml_mac);
            %output_xml =  sprintf('%s%s%s%s%d%d%d%d%d%d%d%d%d%d',output_xml_frame_mac,output_xml_frame_ack,output_xml_frame_rts,output_xml_frame_cts,time_sifs_ack, time_difs_ack, time_slot_ack,time_rts, time_difs_rts, time_slot_rts,time_sifs_cts, time_difs_cts, time_slot_cts);
            %time_to_wait_for_ack = 0;


            delay_per_msdu_without_ack = 0;
            delay_per_msdu_with_ack = 0; 
            
            if (plcp_framing_duration_mac ~= 0)
                time_to_wait_for_ack = time_sifs  + plcp_framing_duration_ack;
                
                delay_per_msdu_without_ack = time_difs + plcp_framing_duration_mac +  time_to_wait_for_ack;%[sec]; case: collision: without ack-frame
                
                delay_per_msdu_with_ack = delay_per_msdu_without_ack; %   + plcp_framing_ack_duration;%[sec]; case: successful transmission
                
                if (use_rts_cts == 1)
                    time_to_wait_for_cts = time_sifs + plcp_framing_duration_cts;
                    delay_per_msdu_without_ack = difs_time + plcp_framing_duration_rts + time_to_wait_for_cts ;%[sec]; case: collision: without ack-frame
                    delay_per_msdu_with_ack = delay_per_msdu_without_ack + time_sifs +  plcp_framing_duration_mac + time_to_wait_for_ack;%[sec]; case: successful transmission            
                end
            end
            %TODO:Warum teilen?
            matrix_duration_delay(index_rates,index_msdu) = delay_per_msdu_without_ack / packet_loss_upper_limit;
           
            % In 3 dimensionale Matrizen einordnen und noch ein paar
            % Rechnungen
            if (delay_per_msdu_without_ack ~= 0 && delay_per_msdu_with_ack ~= 0)
                [vector_backoff_window_size_for_tmt_max_per_neighbour, vector_tmt_max_per_neighbour, vector_number_of_collisions,vector_efficiency_for_tmt_max_per_neighbour,vector_birthday_problem_collision_likelihood ] = func_throughput_efficiency_for_data_rate_packet_size(rate_data,packet_delivery_limit,msdu_size,delay_per_msdu_without_ack, delay_per_msdu_with_ack, time_slot, matrix_counter_slots, matrix_collision,matrix_birthday_problem_collision_likelihood_packet_loss  );
                %[ vector_tmt_max_per_neighbour, vector_number_of_collisions,vector_efficiency_for_tmt_max_per_neighbour,vector_birthday_problem_collision_likelihood ] = func_throughput_efficiency_for_data_rate_packet_size(rate_data,packet_delivery_limit,msdu_size,delay_per_msdu_without_ack, delay_per_msdu_with_ack, time_slot, matrix_counter_slots, matrix_collision,matrix_birthday_problem_collision_likelihood_packet_loss  );
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
                    matrix_tmt_collisions_percent(index_rates,index_msdu,n) = 0;
                    matrix_results_bandwidth_efficient(index_rates,index_msdu,n) = 0;
                    matrix_tmt_backoff_birthday_problem(index_rates,index_msdu,n) = 0;
                    matrix_tmt_backoff_birthday_problem_approximation(index_rates,index_msdu,n) = 0;

                end
            end
        end
    end
    %Ausgabe von figures
    %func_sim_evaluation(vector_rates,vector_msdu_sizes,matrix_tmt_neighbours,matrix_tmt_backoff,matrix_tmt_collisions,matrix_tmt_collisions_percent,matrix_results_bandwidth_efficient,matrix_tmt_backoff_birthday_problem,matrix_collision,matrix_birthday_problem_collision_likelihood_packet_loss,matrix_tmt_backoff_birthday_problem_approximation);
end

