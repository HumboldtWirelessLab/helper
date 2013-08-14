function func_csvwrite_matrix_4D(file_directory,fileanme,matrix_4D)
    for i=1:1:size(matrix_4D,1)
        for j=1:1:size(matrix_4D,2)
            filename_xml = sprintf('%s/%s_%d_%d.csv',file_directory,fileanme,i,j);
            [matrix_3D] = func_convert_matrix_4D_2_3D(matrix_4D,i);
            matrix_2d = func_convert_matrix_3D_2_2D(matrix_3D,j);
            csvwrite(filename_xml,matrix_2d) 
        end
    end
end

