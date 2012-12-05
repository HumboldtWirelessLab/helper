% Berechnung des Durchsatzes und der Effizienz für eine
% bestimmte Datenrate und eine bestimmte Paketgröße
%    matrix_air_capacity =
%    zeros(number_of_neighbours,backoff_window_size_max); für
%    eine bestimmte Anzahl von Nachbarn und
%    Backoff-Fenstergröße
%   matrix_efficiency = zeros(number_of_neighbours,backoff_window_size_max);
% matrix_air_capacity   [Mbps]
% matrix_efficiency     [percent]
function [vector_backoff_window_size_for_tmt_max_per_neighbour, vector_tmt_max_per_neighbour, vector_number_of_collisions,vector_efficiency_for_tmt_max_per_neighbour,vector_birthday_problem_collision_likelihood ] = func_throughput_efficiency_for_data_rate_packet_size(rate_data,packet_delivery_limit,msdu_size,delay_per_msdu_without_ack, delay_per_msdu_with_ack, time_slot, matrix_counter_slots, matrix_collision,matrix_birthday_problem_collision_likelihood_packet_loss  )
                [matrix_air_capacity, matrix_efficiency ] = func_calculation_air_capacity_efficiency(rate_data, packet_delivery_limit,msdu_size,delay_per_msdu_without_ack, delay_per_msdu_with_ack, time_slot, matrix_counter_slots, matrix_collision);
                [ vector_tmt_max_per_neighbour, vector_backoff_window_size_for_tmt_max_per_neighbour ] = func_find_throughput_highest(matrix_air_capacity);
                vector_number_of_collisions = func_find_for_throughput_highest(matrix_collision, vector_backoff_window_size_for_tmt_max_per_neighbour);
                vector_efficiency_for_tmt_max_per_neighbour = func_find_for_throughput_highest(matrix_efficiency, vector_backoff_window_size_for_tmt_max_per_neighbour);
                vector_birthday_problem_collision_likelihood = func_find_for_throughput_highest_2(matrix_birthday_problem_collision_likelihood_packet_loss, vector_backoff_window_size_for_tmt_max_per_neighbour);
                %vector_birthday_problem_collision_likelihood = func_test_birthday_problem_2(vector_backoff_window_size_for_tmt_max_per_neighbour, size(vector_backoff_window_size_for_tmt_max_per_neighbour,1));
                % Save [ vector_rate_current_tmt_max_per_neighbour, vector_rate_current_tmt_max_backoff_window_size ] for later use 
                %m_helper =  vector_number_of_collisions ./ (vector_number_of_collisions + 100);
end

