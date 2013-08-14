function [matrix_diff] = func_comparison_diff_calc(matrix1,matrix2,vector_neighbours,vector_neighbours_filter)
    matrix_diff = zeros(size(matrix1,1),size(vector_neighbours_filter,2));
    matrix_helper = zeros(size(vector_neighbours_filter,2),size(matrix1,2));
    for i = 1:1:size(vector_neighbours,2)
       if ((~isempty(find(vector_neighbours == vector_neighbours_filter(1,i), 1))))
           for j = 1:size(matrix1,2)
               matrix_helper(i,j) = sqrt((matrix1(i,j) - vector_neighbours_filter(1,i))^2  + (matrix2(i,j) - vector_neighbours_filter(1,i))^2);
           end
       end
    end
end

