function [matrix_3D] = func_matrix_3D_csvread(filename_basic,number_of_simulations)
     vector_filenames  = cell(1,number_of_simulations);
     for i = 1:1:number_of_simulations
         string = sprintf('%s.bin_sim_%d.csv',filename_basic,i);
         vector_filenames(1,i) = {string} ;
     end
       matrix_2D = csvread(vector_filenames{1,1});
     matrix_3D = zeros(number_of_simulations,size(matrix_2D,1),size(matrix_2D,2));
     for i=1:1:number_of_simulations
         matrix_2D = csvread(vector_filenames{1,i});
         matrix_3D(i,:,:) = matrix_2D(:,:);
     end
end
