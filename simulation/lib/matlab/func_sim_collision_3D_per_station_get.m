function [matrix_col_occured_simulation_3D_neighbour_backoff_per_station,matrix_likelihood_simulation_3D_collisions_percent_per_station] = func_sim_collision_3D_per_station_get(folder_name,filename,number_of_simulation,matrix_packets_delivered)
%---------------------------------Filenames--------------------------------
    filename_csv = sprintf('%s/%s',folder_name,filename);
     %------------------ Read results of the simulation ------------------------
    [matrix_col_occured_simulation_3D_neighbour_backoff_per_station] = func_matrix_3D_csvread(filename_csv,number_of_simulation);
    %matrix_col_occured_simulation_all_neighbour_backoff_per_station = zeros(size(matrix_col_occured_neighbour_backoff_global_per_station_read,1),size(matrix_col_occured_neighbour_backoff_global_per_station_read,3),size(matrix_col_occured_neighbour_backoff_global_per_station_read,2));
    	
    %for i=1:1:size(matrix_col_occured_neighbour_backoff_global_per_station_read,3)
    %    for p=1:1:size(matrix_col_occured_neighbour_backoff_global_per_station_read,2)
    %        for j=1:1:number_of_simulation
    %            matrix_col_occured_simulation_all_neighbour_backoff_per_station(j,i,p) = matrix_col_occured_neighbour_backoff_global_per_station_read(j,p,i);
    %           
    %        end
    %    end
    %end
     
     
    %[matrix_likelihood_collisions_2] = func_sim_mean_per_station_calculation(matrix_col_occured_simulation_all_neighbour_backoff_per_station,matrix_packets_delivered);
    [matrix_likelihood_simulation_3D_collisions_percent_per_station] = func_sim_mean_per_station_calculation_3D(matrix_col_occured_simulation_3D_neighbour_backoff_per_station,matrix_packets_delivered);
    %[matrix_likelihood_simulation_all_collisions_percent_per_station] = func_matrix_3D_convert_2_percent(matrix_likelihood_collisions_2);
    %matrix_likelihood_simulation_all_collisions_percent_per_station = matrix_likelihood_collisions_2;
    
end

