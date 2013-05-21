function [matrix_packets_delivered_global] = func_sim_packets_delivered_global_get(matrix_packets_delivered_3D)
        [matrix_packets_delivered2] = mean(matrix_packets_delivered_3D,1);
        matrix_packets_delivered_global = zeros(size(matrix_packets_delivered2,2),size(matrix_packets_delivered2,3));     
        for i=1:1:size(matrix_packets_delivered2,2)
            for j=1:1:size(matrix_packets_delivered2,3)
                matrix_packets_delivered_global(i,j) =  matrix_packets_delivered2(1,i,j);
            end
        end
        
        debug = 0;
        if (debug == 1) %veraltet, trotzdem noch überprüfen wegen Abweichung zur neuen Berechnung (Abweichung sollte für beide 0 sein)
            folder_name = 'messungen/v2'; %statisch angeben
            filename = 'sim_packets_delivery_counter_global.csv';
            filename_simulation_configuration = 'simulation_configuration.csv';
            [number_of_simulations] = func_simulation_configuration_get(folder_name,filename_simulation_configuration);
            filename_csv = sprintf('%s/%s',folder_name,filename);
            matrix_2D = csvread(filename_csv);
            matrix_packets_delivered_global = matrix_2D ./ number_of_simulations;   
        end
end

