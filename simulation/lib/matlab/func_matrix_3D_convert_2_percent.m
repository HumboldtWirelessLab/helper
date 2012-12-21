function [matrix_percent] = func_matrix_3D_convert_2_percent(matrix)
    matrix_percent = zeros(size(matrix,1),size(matrix,2),size(matrix,3));
    for p=1:1:size(matrix,3)
        for t=1:1:size(matrix,2)
            for z=1:1:size(matrix,1)
                matrix_percent(z,t,p) = matrix(z,t,p) * 100;
            end
        end
    end
end

