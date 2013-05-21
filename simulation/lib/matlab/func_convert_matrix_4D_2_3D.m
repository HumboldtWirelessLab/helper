function [matrix_3d] = func_convert_matrix_4D_2_3D(matrix_4d,dim1)
    matrix_3d = zeros(size(matrix_4d,2),size(matrix_4d,3),size(matrix_4d,4));
    for i = 1:1:size(matrix_3d,1)
        for j = 1:1:size(matrix_3d,2)
            for z = 1:1:size(matrix_3d,3)
                matrix_3d(i,j,z) = matrix_4d(dim1,i,j,z);
            end
        end
    end
end
