function [matrix_packets_delivered] = func_sim_packets_delivered_global_get(folder_name,number_of_simulations)
    filename = 'sim_packets_delivery_counter_global.csv';
    filename_csv = sprintf('%s/%s',folder_name,filename);
    matrix_2D = csvread(filename_csv);
    matrix_packets_delivered = matrix_2D ./ number_of_simulations;
end

