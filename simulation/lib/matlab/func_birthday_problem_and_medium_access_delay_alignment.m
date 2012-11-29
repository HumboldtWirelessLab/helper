function [vector_neighbours, vector_backoff_birthday_problem_for_cw_min, vector_backoff_medium_access_delay,vector_backoff_window_sizes_per_neighbour,vector_backoff_window_sizes_per_neighbour_approximation] = func_birthday_problem_and_medium_access_delay_alignment ( no_backoff_window_size_max,no_neighbours_max, cw_min,packet_loss_upper_limit )
    % Backoff-Delay Calculation
    %vector_backoff_delay = zeros(1,size(vector_birthday_problem_neighbours,2));
    [vector_neighbours, vector_backoff_window_sizes_per_neighbour,vector_backoff_window_sizes_per_neighbour_approximation, matrix_birthday_problem_collision_likelihood_packet_loss] = func_birthday_problem_calc( no_backoff_window_size_max,no_neighbours_max,packet_loss_upper_limit );
    vector_backoff_birthday_problem_for_cw_min = zeros(1,size(vector_neighbours,2));
    vector_backoff_medium_access_delay = zeros(1,size(vector_neighbours,2));
    for zt=1:1:size(vector_neighbours,2) ;
         vector_backoff_birthday_problem_for_cw_min(1,vector_neighbours(1,zt)) = matrix_birthday_problem_collision_likelihood_packet_loss(zt,cw_min);
         vector_backoff_medium_access_delay(1,vector_neighbours(1,zt)) = func_medium_access_delay(zt, packet_loss_upper_limit, cw_min);
    end
end

