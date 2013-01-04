function [matrix_likelihood_collisions_percent_global,matrix_likelihood_collisions_percent_per_station,matrix_collision_occured_neighbour_backoff_global,matrix_col_occured_neighbour_backoff_global_per_station] = func_sim_collision_get(number_of_simulation,packets_successful_delivered)
%---------------------------------Filenames--------------------------------
    %filename_1 = 'sim_matrix_results_collision_simulation_neighbour_backoff_global';
    filename_2 = 'sim_matrix_counter_collision_sim_neighbour_backoff_global';
    %filename_3 = 'sim_matrix_collision_sim_neighbour_backoff_global_per_station';
    filename_4 = 'sim_matrix_col_occured_sim_neighbour_backoff_global_per_station';
    %filename_5 = 'sim_matrix_results_collision_avg_per_station';
    %--------- Variante  -----------------------------------------------------
    %filename_csv_1 = sprintf('%s/%s',folder_name_2,filename_1);
    filename_csv_2 = sprintf('%s/%s',folder_name,filename_2);
    %filename_csv_3 = sprintf('%s/%s',folder_name_2,filename_3);
    filename_csv_4 = sprintf('%s/%s',folder_name,filename_4);
    %filename_csv_5 = sprintf('%s/%s',folder_name_2,filename_5);
    %------------------ Read results of the simulation ------------------------
    [matrix_collision_occured_neighbour_backoff_global] = func_matrix_3D_csvread(filename_csv_2,number_of_simulation);
    %[matrix_collision_sim_neighbour_backoff_global_per_station] = func_matrix_3D_csvread(filename_csv_3,number_of_simulation);
    [matrix_col_occured_neighbour_backoff_global_per_station] = func_matrix_3D_csvread(filename_csv_4,number_of_simulation);
    
    [matrix_likelihood_collisions_1] = func_sim_mean_per_station_calculation(matrix_collision_occured_neighbour_backoff_global,packets_successful_delivered);
    [matrix_likelihood_collisions_2] = func_sim_mean_per_station_calculation(matrix_col_occured_neighbour_backoff_global_per_station,packets_successful_delivered);
    [matrix_likelihood_collisions_percent_global] = func_matrix_3D_convert_2_percent(matrix_likelihood_collisions_1);
    [matrix_likelihood_collisions_percent_per_station] = func_matrix_3D_convert_2_percent(matrix_likelihood_collisions_2);
end

