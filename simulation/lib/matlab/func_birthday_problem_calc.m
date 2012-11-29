%function [vector_neighbours, vector_backoff_window_sizes_per_neighbour,vector_backoff_window_sizes_per_neighbour_approximation, matrix_birthday_problem_collision_likelihood_packet_loss] = func_birthday_problem_calc(vector_birthday_problem_neighbours,vector_birthday_problem_cw_sizes,packet_loss_upper_limit)
function [vector_backoff_window_sizes_per_neighbour,vector_backoff_window_sizes_per_neighbour_approximation, matrix_birthday_problem_collision_likelihood_packet_loss,counter_of_successful_conditions] = func_birthday_problem_calc(vector_birthday_problem_neighbours,vector_birthday_problem_cw_sizes,packet_loss_upper_limit)    
    %------------packet loss likelihood calculation for different neighbours and different contention window sizes ----------------------------------------------------------
    [matrix_birthday_problem_collision_likelihood_packet_loss] = func_birhtday_problem_packetloss(vector_birthday_problem_neighbours,vector_birthday_problem_cw_sizes);
    %------------ limit packet loss likelihood calculation and therefore search for packet_loss_upper_limit  --------
    [vector_backoff_window_sizes_per_neighbour,counter_of_successful_conditions] = func_birthday_problem_search_backoff_neighbours(matrix_birthday_problem_collision_likelihood_packet_loss,packet_loss_upper_limit);    
    counter_of_successful_conditions = max(counter_of_successful_conditions);
    %[vector_backoff_per_neighbour,vector_counter_of_successful_conditions] = func_birthday_problem_search_backoff_neighbours(matrix_birthday_problem_collision_likelihood_packet_loss,packet_loss_upper_limit);    
    %[ vector_backoff_window_sizes_per_neighbour] = func_test_vector_shorten(vector_backoff_per_neighbour,max(vector_counter_of_successful_conditions));
    %vector_neighbours =1:1:max(vector_counter_of_successful_conditions);
    [vector_backoff_window_sizes_per_neighbour_approximation] = func_backoff_approximation(packet_loss_upper_limit,vector_birthday_problem_neighbours);
    %vector_backoff_window_sizes_per_neighbour_approximation = func_test_vector_shorten(vector_backoff_window_sizes_per_neighbour_approximation,counter_of_successful_conditions);
    counter_max = max(vector_birthday_problem_cw_sizes);
    for search=1:1:size(vector_backoff_window_sizes_per_neighbour_approximation,2)
        if (vector_backoff_window_sizes_per_neighbour_approximation(1,search) > counter_max)
            vector_backoff_window_sizes_per_neighbour_approximation(1,search) = 0;
        end
    end
end

