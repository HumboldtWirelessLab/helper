function [matrix_2d] = func_convert_matrix_3D_2_2D(matrix_3d,dim1)
    matrix_2d = zeros(size(matrix_3d,2),size(matrix_3d,3));
    for i = 1:1:size(matrix_2d,1)
        for j = 1:1:size(matrix_2d,2)
            matrix_2d(i,j) = matrix_3d(dim1,i,j);
        end
    end
end

