function [matrix_4D] = func_csvread_matrix_4D(file_directory,fileanme,size_dim_1,size_dim_2,size_dim_3,size_dim_4)
    matrix_4D = zeros(size_dim_1,size_dim_2,size_dim_3,size_dim_4);
    for i=1:1:size_dim_1
        for j=1:1:size_dim_2
            filename_xml = sprintf('%s/%s_%d_%d.csv',file_directory,fileanme,i,j);
            matrix_2d = csvread(filename_xml); 
            for z = 1:1:size_dim_3
                for t = 1:1:size_dim_4
                    matrix_4D(i,j,z,t) = matrix_2d(z,t);
                end
            end
        end
    end
end

