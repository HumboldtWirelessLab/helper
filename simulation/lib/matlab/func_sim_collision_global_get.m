function [matrix_col_occured_mean_neighbour_backoff_global,matrix_likelihood_collisions_percent_global] = func_sim_collision_global_get(matrix_3D_col_occured_simulation_neighbour_backoff_global,matrix_3D_likelihood_simulation_collisions_percent_global)
    
    matrix_col_occured_mean_neighbour_backoff_global_mean = mean(matrix_3D_col_occured_simulation_neighbour_backoff_global,1);
    matrix_likelihood_collisions_percent_global_mean = mean(matrix_3D_likelihood_simulation_collisions_percent_global,1); 
    
    matrix_col_occured_mean_neighbour_backoff_global = zeros(size(matrix_col_occured_mean_neighbour_backoff_global_mean,2),size(matrix_col_occured_mean_neighbour_backoff_global_mean,3));
    matrix_likelihood_collisions_percent_global = zeros(size(matrix_likelihood_collisions_percent_global_mean,2),size(matrix_likelihood_collisions_percent_global_mean,3));
    %% Eliminate Dimension 1
    for i=1:1:size(matrix_likelihood_collisions_percent_global_mean,2)
         for j=1:1:size(matrix_likelihood_collisions_percent_global_mean,3)
             matrix_col_occured_mean_neighbour_backoff_global(i,j) =  matrix_col_occured_mean_neighbour_backoff_global_mean(1,i,j);
             matrix_likelihood_collisions_percent_global(i,j) =  matrix_likelihood_collisions_percent_global_mean(1,i,j);
         end
    end   
    %%        TODO: has to bee modified in Simulation (change from 0 to 100%)     
    matrix_sim_likelihood_collisions_percent_global2 = matrix_likelihood_collisions_percent_global; 
    for d1 = 1:1:size(matrix_sim_likelihood_collisions_percent_global2,1)
        for d2 = 1:1:size(matrix_sim_likelihood_collisions_percent_global2,1)
            if (matrix_sim_likelihood_collisions_percent_global2(d1,d2) == 0)
                matrix_sim_likelihood_collisions_percent_global2(d1,d2) = 1;
            end
        end
    end
    matrix_likelihood_collisions_percent_global = matrix_sim_likelihood_collisions_percent_global2;
end


