function [matrix_slot_time_global] = func_sim_collision_slots_global_get(folder_name,filename,number_of_simulations)
        filename_csv = sprintf('%s/%s',folder_name,filename);
        %[matrix_mean_no_sim_neighbour_backoff_slots_global_3D, matrix_mean_no_sim_likelihood_collisions_percent_slot_global_3D, matrix_col_occured_simulation_all_neighbour_backoff_global_3D, matrix_likelihood_simulation_all_collisions_percent_global_3D] = func_sim_collision_3D_global_get(folder_name,filename,number_of_simulation,matrix_packets_delivered_3D);
        matrix_2D = csvread(filename_csv);
        matrix_slot_time_global = matrix_2D ./ number_of_simulations;
end

