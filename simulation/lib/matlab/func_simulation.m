function [matrix_results_counter_round_global_packet_delivered_3D, matrix_results_counter_round_global_packet_collided_3D,matrix_results_counter_slots_global_3D,no_neighbours_max,no_backoff_window_size_max] = func_simulation(vector_backoff,vector_neighbours,number_of_simulation,folder_name,write_simulation_results_2_csv)  
%-------------------- Calculation for collision case and non collision case --------------------
    %matrix_collision_likelihood = zeros(1,1); %init
    simulation_of_collision = 2;
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
            packet_delivery_limit = 100;
            [matrix_collision, matrix_collision_likelihood, matrix_counter_slots] = func_simulation_read(folder_name,number_of_simulation,packet_delivery_limit);
            [no_neighbours_max,no_backoff_window_size_max] = size(matrix_collision);
    elseif (simulation_of_collision == 2)
        %--------------- Start collision simulation ---------------------------
        %[matrix_results_packets_delivery_counter_global,matrix_results_counter_slots_global,matrix_results_collision_avg,matrix_results_collision_min,matrix_results_collision_min_counter,matrix_results_collision_max,matrix_results_collision_max_counter,matrix_results_retries_avg,matrix_results_retries_min,matrix_results_retries_min_counter,matrix_results_retries_max,matrix_results_retries_max_counter] = func_simulation_start(number_of_simulation,vector_backoff,no_neighbours_max,packet_delivery_limit);  
        %[matrix_results_packets_delivery_counter_global,matrix_results_counter_slots_global, matrix_results_collision_avg_global,matrix_results_collision_simulation_neighbour_backoff_global,matrix_counter_collision_sim_neighbour_backoff_global,matrix_collision_sim_neighbour_backoff_global_per_station,matrix_col_occured_sim_neighbour_backoff_global_per_station,matrix_results_collision_avg_per_station,matrix_results_collision_avg,matrix_results_collision_min,matrix_results_collision_min_counter,matrix_results_collision_max,matrix_results_collision_max_counter,matrix_results_retries_avg,matrix_results_retries_min,matrix_results_retries_min_counter,matrix_results_retries_max,matrix_results_retries_max_counter] = func_simulation_start(number_of_simulation,vector_backoff,no_neighbours_max,packet_delivery_limit);
        [matrix_results_counter_round_global_packet_delivered_3D, matrix_results_counter_round_global_packet_collided_3D,matrix_results_counter_slots_global_3D] = func_simulation_start(number_of_simulation,vector_backoff,vector_neighbours);
        matrix_collision = matrix_results_counter_round_global_packet_collided;
        %matrix_collision = matrix_results_collision_avg;
        [no_neighbours_max,no_backoff_window_size_max] = size(matrix_collision);
        %matrix_counter_slots = matrix_results_counter_slots_global;
        %--------------- write Simulation results into files  ---------------------------
        if (write_simulation_results_2_csv == 1)
            %mkdir folder_name;
            %func_write_csv_stats(folder_name, matrix_results_packets_delivery_counter_global,matrix_results_counter_slots_global,matrix_results_collision_avg,matrix_results_collision_min,matrix_results_collision_min_counter,matrix_results_collision_max,matrix_results_collision_max_counter,matrix_results_retries_avg,matrix_results_retries_min,matrix_results_retries_min_counter,matrix_results_retries_max,matrix_results_retries_max_counter,matrix_results_collision_avg_global,matrix_results_collision_simulation_neighbour_backoff_global,matrix_counter_collision_sim_neighbour_backoff_global,matrix_collision_sim_neighbour_backoff_global_per_station,matrix_col_occured_sim_neighbour_backoff_global_per_station,matrix_results_collision_avg_per_station);
            func_write_csv_stats_2(folder_name, matrix_results_counter_round_global_packet_delivered_3D, matrix_results_counter_round_global_packet_collided_3D,matrix_results_counter_slots_global_3D);    
        end
    end   
end

