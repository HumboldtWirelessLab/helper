function [matrix_birthday_problem_collision_likelihood_packet_loss_new,matrix_collision_percent_new] = func_birthday_problem_simulation_filter_neighbours(matrix_birthday_problem_collision_likelihood_packet_loss,matrix_collision_percent,vector_neighbours)
    matrix_birthday_problem_collision_likelihood_packet_loss_new = zeros(size(vector_neighbours,2),size(matrix_birthday_problem_collision_likelihood_packet_loss,2));
    matrix_collision_percent_new = zeros(size(vector_neighbours,2),size(matrix_birthday_problem_collision_likelihood_packet_loss,2));
    counter = 1;
    for i=1:1:size(matrix_birthday_problem_collision_likelihood_packet_loss,1)
        if (~isempty(find(vector_neighbours == i, 1)))
            matrix_birthday_problem_collision_likelihood_packet_loss_new(counter,:) = matrix_birthday_problem_collision_likelihood_packet_loss(i,:);
            matrix_collision_percent_new(counter,:) = matrix_collision_percent(i,:);
            counter = counter + 1;
        end
    end
end