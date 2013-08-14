function [matrix_packet_loss_neighbours_backoff_birthday_problem_classic,matrix_packet_loss_neighbours_backoff_windows_birthday_problem,matrix_packet_loss_neighbours_backoff_windows_approximation, matrix_birthday_problem_packet_loss_classic,matrix_birthday_problem_packet_loss,vector_of_successful_conditions_classic,vector_of_successful_conditions] = func_birthday_problem_calc(vector_birthday_problem_neighbours,vector_birthday_problem_cw_sizes,vector_packet_loss_upper_limit)    
    
    %------------packet loss likelihood calculation for different neighbours and different contention window sizes ----------------------------------------------------------
    [matrix_birthday_problem_packet_loss_classic] = func_birhtday_problem_packetloss_classic(vector_birthday_problem_cw_sizes,vector_birthday_problem_neighbours);
    [matrix_birthday_problem_packet_loss] = func_birhtday_problem_packetloss(vector_birthday_problem_cw_sizes,vector_birthday_problem_neighbours);
    
    %------------ limit packet loss likelihood calculation and therefore search for packet_loss_upper_limit  --------
   if (vector_packet_loss_upper_limit(1,1) == -1)
       matrix_packet_loss_neighbours_backoff_birthday_problem_classic = matrix_birthday_problem_packet_loss_classic;
       matrix_packet_loss_neighbours_backoff_windows_birthday_problem = matrix_birthday_problem_packet_loss;
       vector_of_successful_conditions_classic = -1;
       vector_of_successful_conditions = -1;
   else 
    [matrix_packet_loss_neighbours_backoff_birthday_problem_classic,vector_of_successful_conditions_classic] = func_birthday_problem_packet_loss_limit(matrix_birthday_problem_packet_loss_classic,vector_birthday_problem_neighbours,vector_packet_loss_upper_limit);
    [matrix_packet_loss_neighbours_backoff_windows_birthday_problem,vector_of_successful_conditions] = func_birthday_problem_packet_loss_limit(matrix_birthday_problem_packet_loss,vector_birthday_problem_neighbours,vector_packet_loss_upper_limit);
   end
   %------------ packet loss birthday problem approxiation  --------
    [matrix_packet_loss_neighbours_backoff_windows_approximation] = func_backoff_approximation(vector_packet_loss_upper_limit,vector_birthday_problem_neighbours);
    %counter_max = max(vector_birthday_problem_cw_sizes);
    %for search=1:1:size(matrix_packet_loss_neighbours_backoff_windows_approximation,2)
    %    if (matrix_packet_loss_neighbours_backoff_windows_approximation(1,search) > counter_max)
    %        matrix_packet_loss_neighbours_backoff_windows_approximation(1,search) = 0;
    %    end
    %end
end

