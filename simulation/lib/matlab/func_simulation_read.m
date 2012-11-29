function [matrix_collision, matrix_counter_slots] = func_simulation_read (folder_name)
        folder_data_measurement = folder_name;%sprintf('messungen/2012-09-08');
        sim_data_collision = sprintf('%s/sim_collision_avg.csv',folder_data_measurement);
        sim_data_counter_slots = sprintf('%s/sim_counter_slots_global.csv',folder_data_measurement);
        matrix_collision = csvread(sim_data_collision);
        matrix_counter_slots = csvread(sim_data_counter_slots);
end

