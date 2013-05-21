function [matrix_col_occured_simulation_all_neighbour_backoff_global] = func_sim_collision_3D_global_get(folder_name,filename,number_of_simulation)%,read_3D_on) %,packets_successful_delivered)
%---------------------------------Filenames--------------------------------
    filename_csv = sprintf('%s/%s',folder_name,filename);
  
    %------------------ Read results of the simulation ------------------------
    [matrix_col_occured_simulation_all_neighbour_backoff_global] = func_matrix_3D_csvread(filename_csv,number_of_simulation);
    %matrix_col_occured_simulation_all_neighbour_backoff_global = zeros(size(matrix_col_occured_neighbour_backoff_global_read,1),size(matrix_col_occured_neighbour_backoff_global_read,3),size(matrix_col_occured_neighbour_backoff_global_read,2));
    	
    %for i=1:1:size(matrix_col_occured_neighbour_backoff_global_read,3)
    %    for p=1:1:size(matrix_col_occured_neighbour_backoff_global_read,2)
    %        for j=1:1:number_of_simulation
    %            matrix_col_occured_simulation_all_neighbour_backoff_global(j,i,p) = matrix_col_occured_neighbour_backoff_global_read(j,p,i);
    %           
    %        end
    %    end
    %end
    
    %matrix_col_occured_mean_neighbour_backoff_global_mean = mean(matrix_col_occured_simulation_all_neighbour_backoff_global,1);
    %[matrix_likelihood_simulation_all_collisions_percent_global] = func_sim_mean_per_station_calculation_3D(matrix_col_occured_simulation_all_neighbour_backoff_global, matrix_packets_delivered);
    %[matrix_likelihood_collisions_2] = func_sim_mean_per_station_calculation(matrix_col_occured_simulation_all_neighbour_backoff_global,matrix_packets_delivered);
    %[matrix_likelihood_simulation_all_collisions_percent_global] = func_matrix_3D_convert_2_percent(matrix_likelihood_collisions);
    %matrix_likelihood_simulation_all_collisions_percent_global = matrix_likelihood_collisions_2; 
    %matrix_likelihood_collisions_percent_global_mean = mean(matrix_likelihood_simulation_all_collisions_percent_global,1);
    
    %matrix_col_occured_mean_neighbour_backoff_global = zeros(size(matrix_col_occured_simulation_all_neighbour_backoff_global,3),size(matrix_col_occured_simulation_all_neighbour_backoff_global,2));
    %matrix_likelihood_collisions_percent_global = zeros(size(matrix_col_occured_simulation_all_neighbour_backoff_global,3),size(matrix_col_occured_simulation_all_neighbour_backoff_global,2));
    %for i=1:1:size(matrix_col_occured_simulation_all_neighbour_backoff_global,2)
     %    for j=1:1:size(matrix_col_occured_simulation_all_neighbour_backoff_global,3)
     %        matrix_col_occured_mean_neighbour_backoff_global(j,i) =  matrix_col_occured_mean_neighbour_backoff_global_mean(1,i,j);
     %        matrix_likelihood_collisions_percent_global(j,i) =  matrix_likelihood_collisions_percent_global_mean(1,i,j);
     %    end
     %end
end

