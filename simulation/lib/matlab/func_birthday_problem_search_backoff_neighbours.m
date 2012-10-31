function [matrix_neighbour_backoff,counter_of_successful_conditions] = func_birthday_problem_search_backoff_neighbours(matrix_birthday_problem_collision_likelihood_packet_loss,packet_loss_upper_limit)

 [number_of_neighbours_max,number_of_backoff_window_max] = size(matrix_birthday_problem_collision_likelihood_packet_loss);
 matrix_neighbour_backoff = zeros(number_of_neighbours_max,1);
 first_time = 0;
 counter_of_successful_conditions = zeros(number_of_neighbours_max,1);
 for i=1:1:number_of_neighbours_max
     for j = 1:1:number_of_backoff_window_max
         if ((matrix_birthday_problem_collision_likelihood_packet_loss(i,j) <=packet_loss_upper_limit) && first_time == 0)
             matrix_neighbour_backoff(i,1) = j;
             first_time = 1;
             counter_of_successful_conditions(i,1) = i;
         end
     end
     first_time = 0;
  end
end