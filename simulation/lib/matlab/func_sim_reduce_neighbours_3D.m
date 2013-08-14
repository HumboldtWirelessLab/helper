function [matrix_3D_result] = func_sim_reduce_neighbours_3D(matrix_3D,vector_no_neighbours,vector_filter_neighbours)
    matrix_3D_result = zeros(size(matrix_3D,1),size(matrix_3D,2),size(vector_filter_neighbours,2));
    counter_vec_filter = 0;
    for i = 1:1:size(vector_no_neighbours,2)
        if ((~isempty(find(vector_filter_neighbours == vector_no_neighbours(1,i), 1))))
            counter_vec_filter = counter_vec_filter + 1;
            matrix_3D_result(:,:,counter_vec_filter) = matrix_3D(:,:,i);
        end
    end
end

