function [matrix_packet_loss_neighbours_backoff_windows_birthday_problem,vector_of_successful_conditions] = func_birthday_problem_packet_loss_limit(matrix_birthday_problem_packet_loss,vector_birthday_problem_neighbours,vector_packet_loss_upper_limit)
    vector_of_successful_conditions = zeros(1,size(vector_packet_loss_upper_limit,2));
    matrix_packet_loss_neighbours_backoff_windows_birthday_problem= zeros(size(vector_packet_loss_upper_limit,2),size(vector_birthday_problem_neighbours,2));
    for i=1:1:size(vector_packet_loss_upper_limit,2)    
        [vector_backoff_window_sizes_per_neighbour,counter_of_successful_conditions] = func_birthday_problem_search_backoff_neighbours(matrix_birthday_problem_packet_loss,vector_packet_loss_upper_limit(1,i));    
        vector_of_successful_conditions(1,i) = max(counter_of_successful_conditions);
        for t=1:1:size(vector_birthday_problem_neighbours,2) % Voraussetzung table_backoff_windows und table_neighbours haben die gleiche Anzahl von Elementen
            matrix_packet_loss_neighbours_backoff_windows_birthday_problem(i,t) = vector_backoff_window_sizes_per_neighbour(1,t);  
        end
    end
end

