function [matrix_packets_delivered] = func_sim_packets_delivered_global_get(folder_name,number_of_simulations,read_3D_on)
    if (read_3D_on == 0)
        filename = 'sim_packets_delivery_counter_global.csv';
        filename_csv = sprintf('%s/%s',folder_name,filename);
        matrix_2D = csvread(filename_csv);
        matrix_packets_delivered = matrix_2D ./ number_of_simulations;
    else
        filename = 'sim_matrix_results_collision_simulation_neighbour_backoff_global';
        filename_csv = sprintf('%s/%s',folder_name,filename);
        [matrix_packets_delivered_read] = func_matrix_3D_csvread(filename_csv,number_of_simulations);
        matrix_packets_delivered = zeros(size(matrix_packets_delivered_read,1),size(matrix_packets_delivered_read,3),size(matrix_packets_delivered_read,2));
        for i=1:1:size(matrix_packets_delivered_read,3)
            for p=1:1:size(matrix_packets_delivered_read,2)
                for j=1:1:number_of_simulations
                matrix_packets_delivered(j,i,p) = matrix_packets_delivered_read(j,p,i);              
                end
            end
        end
    end
end

