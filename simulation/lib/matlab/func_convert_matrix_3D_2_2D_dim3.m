function [matrix_2d] = func_convert_matrix_3D_2_2D_dim3(matrix_3d,dim3)
    matrix_2d = zeros(size(matrix_3d,1),size(matrix_3d,2));
    for i = 1:1:size(matrix_2d,1)
        for j = 1:1:size(matrix_2d,2)
            matrix_2d(i,j) = matrix_3d(i,j,dim3);
        end
    end
end