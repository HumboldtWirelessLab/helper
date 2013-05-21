function [vector_minimum,vector_backoff_per_neighbour] = func_evaluation_matrix_search_4_minimum_greater_zero(matrix)
    vector_minimum = zeros(1,size(matrix,1));
    vector_backoff_per_neighbour = zeros(1,size(matrix,1));
    for i=1:1:size(matrix,1)
        vector_minimum(1,i) = - 1;
    end
    for i=1:1:size(matrix,1)
        for j=1:1:size(matrix,2)
            if(matrix(i,j) > 0 && vector_minimum(1,i) == -1)
                vector_minimum(1,i) = matrix(i,j);
                vector_backoff_per_neighbour(1,i) = j;
            elseif (matrix(i,j) > 0 && matrix(i,j) < vector_minimum(1,i))
                vector_minimum(1,i) = matrix(i,j);
                vector_backoff_per_neighbour(1,i) = j;
            end
        end
    end
end

