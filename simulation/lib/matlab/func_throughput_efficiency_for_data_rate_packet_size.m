%% * Function <func_throughput_efficiency_for_data_rate_packet_size> calculate the contention-window-size 
%       for a special number of neighbours to achive the theoretical max.
%       thourghput (TMT) or the highest efficiency
%       
% @params   matrix_number_of_slots       - Average Number of slots were needed for frame transmission per[number_of_neighbours,backoff_window_size]   
%           matrix_number_of_collisions   - Average Number of collision were - needed for frame transmission per[number_of_neighbours,backoff_window_size] 
%           phy_rate_basic             -  lowest physical rate used by the current stanndard (used for calculate bandwidth efficiency [bps])
%           matrix_number_of_packets_delivered  - how many packets were received by the receiving station
%           msdu_size                    - MSDU size in [byte]
%           delay_per_msdu_successful   - if a frame-transmission was succefull 
%           delay_per_msdu_unsuccessful - if a frame-transmission ws unsuccessful( collision has occurred)
%           time_slot                    - Backoff-Slot-time in [sec] (depend of the Standards)
%
% @return   vector_tmt_air_capacity_max        - TMT air capacity max for each neighbour
%           vector_tmt_index_backoff_max      - TMT backoff_max_index for each neighbour  
%           vector_number_of_collisions  - Occurred collision depended of vector_tmt_index_backoff_max
%           vector_efficiency_for_tmt    - Efficiency depended of vector_tmt_index_backoff_max
%%
%function [vector_backoff_window_size_for_tmt_max_per_neighbour, vector_tmt_max_per_neighbour, vector_number_of_collisions,vector_efficiency_for_tmt_max_per_neighbour,vector_birthday_problem_collision_likelihood ] = func_throughput_efficiency_for_data_rate_packet_size(phy_rate_current,number_of_packets_delivered,msdu_size,delay_per_msdu_successful, delay_per_msdu_unsuccessful, time_slot, matrix_number_of_slots, matrix_number_of_collision,matrix_birthday_problem_collision_likelihood_packet_loss)
function [vector_tmt_air_capacity_max, vector_tmt_index_backoff_max, vector_number_of_collisions,vector_efficiency_for_tmt,matrix_collisions_backoff,matrix_collisions_air_capacity,matrix_collisions_efficiency] = func_throughput_efficiency_for_data_rate_packet_size(matrix_number_of_slots, matrix_number_of_collisions, phy_rate_basic,matrix_number_of_packets_delivered,msdu_size,delay_per_msdu_successful, delay_per_msdu_unsuccessful, time_slot, vector_packet_loss_upper_limit)
    
    [matrix_air_capacity, matrix_efficiency] = func_calculation_air_capacity_efficiency(phy_rate_basic,matrix_number_of_packets_delivered,msdu_size,delay_per_msdu_successful,delay_per_msdu_unsuccessful, time_slot, matrix_number_of_slots, matrix_number_of_collisions);   
    %[vector_tmt_max_per_neighbour, vector_backoff_window_size_for_tmt_max_per_neighbour ] = func_find_throughput_highest(matrix_air_capacity);
    [vector_tmt_air_capacity_max, vector_tmt_index_backoff_max] = func_find_throughput_highest(matrix_air_capacity);
    [vector_number_of_collisions] = func_find_for_throughput_highest_2(matrix_number_of_collisions, vector_tmt_index_backoff_max);
    [vector_efficiency_for_tmt] = func_find_for_throughput_highest_2(matrix_efficiency, vector_tmt_index_backoff_max);
    
    [matrix_collisions_backoff] = func_search_likelihood_collision_upper_limit(matrix_number_of_collisions,vector_packet_loss_upper_limit);
    [matrix_collisions_air_capacity] = func_find_in_matrix_throughput_highest(matrix_air_capacity, matrix_collisions_backoff);
    [matrix_collisions_efficiency] = func_find_in_matrix_throughput_highest(matrix_efficiency, matrix_collisions_backoff);
    %vector_efficiency_for_tmt_max_per_neighbour = func_find_for_throughput_highest(matrix_efficiency, vector_backoff_window_size_for_tmt_max_per_neighbour);
    %vector_birthday_problem_collision_likelihood = func_find_for_throughput_highest_2(matrix_birthday_problem_collision_likelihood_packet_loss, vector_backoff_window_size_for_tmt_max_per_neighbour);
    %vector_birthday_problem_collision_likelihood = func_test_birthday_problem_2(vector_backoff_window_size_for_tmt_max_per_neighbour, size(vector_backoff_window_size_for_tmt_max_per_neighbour,1));
    % Save [ vector_rate_current_tmt_max_per_neighbour, vector_rate_current_tmt_max_backoff_window_size ] for later use 
    %m_helper =  vector_number_of_collisions ./ (vector_number_of_collisions + 100);
end

