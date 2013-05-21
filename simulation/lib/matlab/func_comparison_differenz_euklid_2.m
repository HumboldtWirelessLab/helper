% @params: matrix1 - values to be calculated
%         matrix2 - values to be calculated
%         vector_neighbours - number of neighbours in matrix1 and matrix2,
%         vector_neighbours_filter - filter matrix1 and matrix2 for special number of neighbours
%         vector_likelihood_filter - filter matrix1 and matrix2 for special number of likelihoods
% @return:
%           matrix_diff[vector_likelihood_filter][vector_neighbours_filter][results]
%               where [results] are:
%                   1 -  different values of vector_likelihood_filter(1,t) (x-value)
%                   2 -  distanz between the x-value of matrix1 and vector_likelihood_filter(1,t
%                   3 - y-value of matrix1 of the x-value
%                   4 - y-value of matrix2 of the x-value
%                   5 - euklidian distance between 3 and 4, if the x-value of matrix1 != vector_likelihood_filter(1,t) => linear interpolation
function [matrix_diff] = func_comparison_differenz_euklid_2(matrix1,matrix2,vector_neighbours,vector_neighbours_filter,vector_likelihood_filter)
    matrix_diff = zeros(size(vector_likelihood_filter,2),size(vector_neighbours_filter,2),5);
    
    counter = 0;
    for t = 1:1:size(vector_likelihood_filter,2) % get one value for likelihood filter
        vector_distanz_min =  - ones(1,size(vector_neighbours_filter,2));
        counter_vector_distanz_min = 0;
        counter = counter + 1;
        counter1 = 0;
        for i = 1:1:size(vector_neighbours,2) % search for likelihood about all neighbours
            if ((~isempty(find(vector_neighbours_filter == vector_neighbours(1,i), 1))))            
                counter1 = counter1 + 1;
                counter_vector_distanz_min = counter_vector_distanz_min + 1;
                for j = 1:size(matrix1,2) %search columns in matrix1 for a value, which is exactly or near the likelihood-value
                   distanz =  sqrt((matrix1(i,j) - vector_likelihood_filter(1,t))^2);
                   if ((vector_distanz_min(1,counter_vector_distanz_min) == -1) || (distanz < vector_distanz_min(1,counter_vector_distanz_min)))
                       vector_distanz_min(1,counter_vector_distanz_min) = distanz;
                       matrix_diff(counter,counter1,1) = vector_likelihood_filter(1,t); % x-value (likelihood)
                       matrix_diff(counter,counter1,2) = distanz; % distance
                       distanz_signed = sign(matrix1(i,j) - vector_likelihood_filter(1,t)); % look for the first point
                       if (distanz_signed == 0) % the likelihood is exactly found in matrix1(i,j) and the euklidian distance can be calculated
                            matrix_diff(counter,counter1,3) = matrix1(i,j); % y-value of matrix1
                            matrix_diff(counter,counter1,4) = matrix2(i,j); % y-value of matrix2
                            matrix_diff(counter,counter1,5) = sqrt((matrix1(i,j) - vector_likelihood_filter(1,t))^2 + (matrix2(i,j) - vector_likelihood_filter(1,t))^2); % euklidian distance
                       elseif (distanz_signed == 1) % the likelihood is not exactly found in found matrix1(i,j) and the linear interpolation has to be started 
                           matrix_diff(counter,counter1,3) = matrix1(i,j); % y-value of matrix1
                           if ((j-1) > 0) %  true, if it is not the marigin of matrix1
                                matrix_diff(counter,counter1,4) = matrix2(i,j) + (vector_likelihood_filter(1,t) - matrix1(i,j)) / (matrix1(i,j-1) - matrix1(i,j)) * (matrix2(i,j-1) - matrix2(i,j));
                                matrix_diff(counter,counter1,5) = sqrt((vector_likelihood_filter(1,t) - vector_likelihood_filter(1,t))^2 + (matrix_diff(counter,counter1,4) - vector_likelihood_filter(1,t))^2); 
                           else %we are in a marigin and can not calculate the value
                               matrix_diff(counter,counter1,4) = -1;
                               matrix_diff(counter,counter1,5) = -1;
                           end
                       elseif (distanz_signed == -1) % the likelihood is not exactly found in found matrix1(i,j) and the linear interpolation has to be started 
                           matrix_diff(counter,counter1,3) = matrix1(i,j);
                           if ((j+1) <= size(matrix2,2))
                                matrix_diff(counter,counter1,4) = matrix2(i,j) + (vector_likelihood_filter(1,t) - matrix1(i,j)) / (matrix1(i,j+1) - matrix1(i,j)) * (matrix2(i,j+1) - matrix2(i,j));
                                matrix_diff(counter,counter1,5) = sqrt((vector_likelihood_filter(1,t) - vector_likelihood_filter(1,t))^2 + (matrix_diff(counter,counter1,4) - vector_likelihood_filter(1,t))^2); 
                           else
                               matrix_diff(counter,counter1,4) = -1;
                               matrix_diff(counter,counter1,5) = -1;
                           end
                       end
                    end
               end
           end
       end
    end
end