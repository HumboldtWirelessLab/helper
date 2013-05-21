function [matrix_packets_delivered] = func_sim_packets_delivered_3D_global_get(folder_name,filename,number_of_simulations) %,read_3D_on)
    filename_csv = sprintf('%s/%s',folder_name,filename);
    [matrix_packets_delivered] = func_matrix_3D_csvread(filename_csv,number_of_simulations);
    %matrix_packets_delivered = zeros(size(matrix_packets_delivered_read,1),size(matrix_packets_delivered_read,3),size(matrix_packets_delivered_read,2));
    %for i=1:1:size(matrix_packets_delivered_read,3)
    %    for p=1:1:size(matrix_packets_delivered_read,2)
    %        for j=1:1:number_of_simulations
    %            matrix_packets_delivered(j,i,p) = matrix_packets_delivered_read(j,p,i);              
    %        end
    %    end
    %end
end

