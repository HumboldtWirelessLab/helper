function [matrix_collision,no_neighbours_max,no_backoff_window_size_max, matrix_counter_slots] = func_simulation(simulation_of_collision,vector_backoff,no_neighbours_max,packet_delivery_limit,number_of_simulation,folder_name,write_simulation_results_2_csv)  
%-------------------- Calculation for collision case and non collision case --------------------
    if (simulation_of_collision == 0)
        number_of_neighbours = 1;
        backoff_window_size_max = 1;
        matrix_counter_slots = zeros(number_of_neighbours,backoff_window_size_max);
        matrix_collision = zeros(number_of_neighbours,backoff_window_size_max);
        for n=1:1:number_of_neighbours
            for k=1:1:backoff_window_size_max
                matrix_counter_slots(n,k) = min(vector_backoff) / 2;               
            end
        end   
    elseif (simulation_of_collision == 1)
            [matrix_collision, matrix_counter_slots] = func_simulation_read (folder_name);
            [no_neighbours_max,no_backoff_window_size_max] = size(matrix_collision);
    elseif (simulation_of_collision == 2)
        %--------------- Start collision simulation ---------------------------
        [matrix_results_packets_delivery_counter_global,matrix_results_counter_slots_global,matrix_results_collision_avg,matrix_results_collision_min,matrix_results_collision_min_counter,matrix_results_collision_max,matrix_results_collision_max_counter,matrix_results_retries_avg,matrix_results_retries_min,matrix_results_retries_min_counter,matrix_results_retries_max,matrix_results_retries_max_counter] = func_simulation_start(number_of_simulation,vector_backoff,no_neighbours_max,packet_delivery_limit);  
        matrix_collision = matrix_results_collision_avg;
        [no_neighbours_max,no_backoff_window_size_max] = size(matrix_collision);
        matrix_counter_slots = matrix_results_counter_slots_global;
        %--------------- write Simulation results into files  ---------------------------
        if (write_simulation_results_2_csv == 1)
            func_write_csv_stats(folder_name, matrix_results_packets_delivery_counter_global,matrix_results_counter_slots_global,matrix_results_collision_avg,matrix_results_collision_min,matrix_results_collision_min_counter,matrix_results_collision_max,matrix_results_collision_max_counter,matrix_results_retries_avg,matrix_results_retries_min,matrix_results_retries_min_counter,matrix_results_retries_max,matrix_results_retries_max_counter);
        end
    end   
end

