function [matrix_diff] = func_comparison_differenz_euklid(matrix1,matrix2,vector_neighbours,vector_neighbours_filter,vector_likelihood_filter)
    matrix_diff = zeros(size(vector_neighbours_filter,2) * size(vector_likelihood_filter,2),5);
    counter1 = 0;
    for t = 1:1:size(vector_likelihood_filter,2)
        vector_distanz_min =  - ones(1,size(vector_neighbours_filter,2));
        counter_vector_distanz_min = 0;
        for i = 1:1:size(vector_neighbours,2)
            if ((~isempty(find(vector_neighbours_filter == vector_neighbours(1,i), 1))))            
                counter1 = counter1 + 1;
                counter_vector_distanz_min = counter_vector_distanz_min + 1;
                for j = 1:size(matrix1,2) %search for one value, which is near the likelihood-value
                   distanz =  sqrt((matrix1(i,j) - vector_likelihood_filter(1,t))^2);
                   if ((vector_distanz_min(1,counter_vector_distanz_min) == -1) || (distanz < vector_distanz_min(1,counter_vector_distanz_min)))
                       vector_distanz_min(1,counter_vector_distanz_min) = distanz;
                       matrix_diff(counter1,1) = vector_likelihood_filter(1,t);
                       matrix_diff(counter1,2) = distanz;
                       distanz_signed = sign(matrix1(i,j) - vector_likelihood_filter(1,t));
                       if (distanz_signed == 0)
                            matrix_diff(counter1,3) = matrix1(i,j);
                            matrix_diff(counter1,4) = matrix2(i,j);
                            matrix_diff(counter1,5) = sqrt((matrix1(i,j) - vector_likelihood_filter(1,t))^2 + (matrix2(i,j) - vector_likelihood_filter(1,t))^2); 
                       elseif (distanz_signed == 1)
                           matrix_diff(counter1,3) = matrix1(i,j);
                           if ((j-1) > 0)
                                matrix_diff(counter1,4) = matrix2(i,j) + (vector_likelihood_filter(1,t) - matrix1(i,j)) / (matrix1(i,j-1) - matrix1(i,j)) * (matrix2(i,j-1) - matrix2(i,j));
                                matrix_diff(counter1,5) = sqrt((vector_likelihood_filter(1,t) - vector_likelihood_filter(1,t))^2 + (matrix_diff(counter1,4) - vector_likelihood_filter(1,t))^2); 
                           else
                               matrix_diff(counter1,4) = -1;
                               matrix_diff(counter1,5) = -1;
                           end
                       elseif (distanz_signed == -1)
                           matrix_diff(counter1,3) = matrix1(i,j);
                           if ((j+1) <= size(matrix2,2))
                                matrix_diff(counter1,4) = matrix2(i,j) + (vector_likelihood_filter(1,t) - matrix1(i,j)) / (matrix1(i,j+1) - matrix1(i,j)) * (matrix2(i,j+1) - matrix2(i,j));
                                matrix_diff(counter1,5) = sqrt((vector_likelihood_filter(1,t) - vector_likelihood_filter(1,t))^2 + (matrix_diff(counter1,4) - vector_likelihood_filter(1,t))^2); 
                           else
                               matrix_diff(counter1,4) = -1;
                               matrix_diff(counter1,5) = -1;
                           end
                       end
                    end
               end
           end
       end
    end
end

