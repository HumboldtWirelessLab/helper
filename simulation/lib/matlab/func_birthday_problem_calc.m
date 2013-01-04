%function [vector_neighbours, vector_backoff_window_sizes_per_neighbour,vector_backoff_window_sizes_per_neighbour_approximation, matrix_birthday_problem_collision_likelihood_packet_loss] = func_birthday_problem_calc(vector_birthday_problem_neighbours,vector_birthday_problem_cw_sizes,packet_loss_upper_limit)
function [matrix_packet_loss_neighbours_backoff_windows_birthday_problem,matrix_packet_loss_neighbours_backoff_windows_approximation, matrix_birthday_problem_collision_likelihood_packet_loss,vector_of_successful_conditions] = func_birthday_problem_calc(vector_birthday_problem_neighbours,vector_birthday_problem_cw_sizes,vector_packet_loss_upper_limit)    
    %------------packet loss likelihood calculation for different neighbours and different contention window sizes ----------------------------------------------------------
    [matrix_birthday_problem_collision_likelihood_packet_loss] = func_birhtday_problem_packetloss(vector_birthday_problem_neighbours,vector_birthday_problem_cw_sizes);
    %------------ limit packet loss likelihood calculation and therefore search for packet_loss_upper_limit  --------
    vector_of_successful_conditions = zeros(1,size(vector_packet_loss_upper_limit,2));
    matrix_packet_loss_neighbours_backoff_windows_birthday_problem= zeros(size(vector_packet_loss_upper_limit,2),size(vector_birthday_problem_neighbours,2));
    for i=1:1:size(vector_packet_loss_upper_limit,2)
        [vector_backoff_window_sizes_per_neighbour,counter_of_successful_conditions] = func_birthday_problem_search_backoff_neighbours(matrix_birthday_problem_collision_likelihood_packet_loss,vector_packet_loss_upper_limit(1,i));    
        vector_of_successful_conditions(1,i) = max(counter_of_successful_conditions);
        for t=1:1:size(vector_birthday_problem_neighbours,2) % Voraussetzung table_backoff_windows und table_neighbours haben die gleiche Anzahl von Elementen
        matrix_packet_loss_neighbours_backoff_windows_birthday_problem(i,t) = vector_backoff_window_sizes_per_neighbour(1,t);  
        end
    end
    %[vector_backoff_per_neighbour,vector_counter_of_successful_conditions] = func_birthday_problem_search_backoff_neighbours(matrix_birthday_problem_collision_likelihood_packet_loss,packet_loss_upper_limit);    
    %[ vector_backoff_window_sizes_per_neighbour] = func_test_vector_shorten(vector_backoff_per_neighbour,max(vector_counter_of_successful_conditions));
    %vector_neighbours =1:1:max(vector_counter_of_successful_conditions);
    [matrix_packet_loss_neighbours_backoff_windows_approximation] = func_backoff_approximation(vector_packet_loss_upper_limit,vector_birthday_problem_neighbours);
    %vector_backoff_window_sizes_per_neighbour_approximation = func_test_vector_shorten(vector_backoff_window_sizes_per_neighbour_approximation,counter_of_successful_conditions);
    counter_max = max(vector_birthday_problem_cw_sizes);
    for search=1:1:size(matrix_packet_loss_neighbours_backoff_windows_approximation,2)
        if (matrix_packet_loss_neighbours_backoff_windows_approximation(1,search) > counter_max)
            matrix_packet_loss_neighbours_backoff_windows_approximation(1,search) = 0;
        end
    end
end

