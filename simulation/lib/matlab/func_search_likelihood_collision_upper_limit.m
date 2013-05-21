function [matrix_backoff] = func_search_likelihood_collision_upper_limit(matrix_number_of_collisions,vector_packet_loss_upper_limit)
    matrix_likelihood_collisions = zeros(size(matrix_number_of_collisions,1), size(matrix_number_of_collisions,2));
    matrix_search = zeros(size(matrix_number_of_collisions,1), size(vector_packet_loss_upper_limit,2));
    matrix_backoff = zeros(size(matrix_number_of_collisions,1), size(vector_packet_loss_upper_limit,2));
    for index = 1:1:size(vector_packet_loss_upper_limit,2)
    for i = 1:1:size(matrix_number_of_collisions,1)
        for j = 1:1:size(matrix_number_of_collisions,2)
            if ((matrix_number_of_collisions(i,j) + 100) > 0)
                matrix_likelihood_collisions(i,j) = (matrix_number_of_collisions(i,j) / (matrix_number_of_collisions(i,j) + 100)); %ratio [dezimal]
            end
             if ((matrix_search(i,index) == 0) && (matrix_likelihood_collisions(i,j) > 0))
                matrix_search(i,index) = matrix_likelihood_collisions(i,j);
                matrix_backoff(i,index) = j;
            elseif (matrix_likelihood_collisions(i,j) >= vector_packet_loss_upper_limit(1,index))
                matrix_search(i,index) = matrix_likelihood_collisions(i,j);
                matrix_backoff(i,index) = j;
            end
        end
    end
    end
    value_max = size(matrix_number_of_collisions,2);
    for i = 1:1:size(matrix_backoff,2)
        vector_pos_indices = find(matrix_backoff(:,i) == value_max)';
        if (~isempty(vector_pos_indices))
            for j = 1:1:size(vector_pos_indices,2)
                value_rounded = round(matrix_likelihood_collisions(vector_pos_indices(1,j),value_max) * 100) / 100;
                if (value_rounded > vector_packet_loss_upper_limit(1,i))
                    matrix_backoff(vector_pos_indices(1,j),i) = -1;
                end
            end
        end
    end
end

