function [matrix_collision, matrix_collision_likelihood, matrix_counter_slots] = func_simulation_read (folder_name,number_of_simulation,packets_successful_delivered)
        folder_data_measurement = folder_name;%sprintf('messungen/2012-09-08');
        %sim_data_collision = sprintf('%s/sim_collision_avg.csv',folder_data_measurement);
        [matrix_collision,matrix_collision_likelihood,matrix_col_occured_simulation_all_neighbour_backoff_per_station,matrix_likelihood_simulation_all_collisions_percent_per_station] = func_sim_collision_per_station_get(folder_name,number_of_simulation,packets_successful_delivered);

        sim_data_counter_slots = sprintf('%s/sim_counter_slots_global.csv',folder_data_measurement);
        
        matrix_counter_slots = csvread(sim_data_counter_slots);
end

