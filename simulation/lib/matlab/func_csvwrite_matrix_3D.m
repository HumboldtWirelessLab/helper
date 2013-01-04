function func_csvwrite_matrix_3D(fileanme,matrix_3D)
    for i=1:1:size(matrix_3D,1)
        filename_xml = sprintf('%s_sim_%d.csv',fileanme,i);
        matrix_2d = func_convert_matrix_3D_2_2D(matrix_3D,i);
        csvwrite(filename_xml,matrix_2d) 
    end
end

