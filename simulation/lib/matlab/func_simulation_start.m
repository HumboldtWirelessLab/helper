%function [matrix_results_packets_delivery_counter_global,matrix_results_counter_slots_global, matrix_results_collision_avg_global,matrix_results_collision_simulation_neighbour_backoff_global,matrix_counter_collision_sim_neighbour_backoff_global,matrix_collision_sim_neighbour_backoff_global_per_station,matrix_col_occured_sim_neighbour_backoff_global_per_station,matrix_results_collision_avg_per_station,matrix_results_collision_avg,matrix_results_collision_min,matrix_results_collision_min_counter,matrix_results_collision_max,matrix_results_collision_max_counter,matrix_results_retries_avg,matrix_results_retries_min,matrix_results_retries_min_counter,matrix_results_retries_max,matrix_results_retries_max_counter] = func_simulation_start(number_of_simulation,vector_backoff,no_neighbours_max,packet_delivery_limit )
function [matrix_results_counter_round_global_packet_delivered, matrix_results_counter_round_global_packet_collided,matrix_results_counter_slots_global] = func_simulation_start(number_of_simulation,vector_backoff,vector_neighbours)

%------------------------ Simulation start point --------------------------------------------------------------------------
    % Initialization of matrixes
    
    %   Initialization for collisions
    %matrix_results_collision_min = zeros(no_neighbours_max,size(vector_backoff,2));
    %matrix_results_collision_min_counter = zeros(no_neighbours_max,size(vector_backoff,2));
    %matrix_results_collision_max = zeros(no_neighbours_max,size(vector_backoff,2));
    %matrix_results_collision_max_counter = zeros(no_neighbours_max,size(vector_backoff,2));
    %matrix_results_collision_avg  = zeros(no_neighbours_max,size(vector_backoff,2));
    
    %matrix_results_collision_avg_global = zeros(no_neighbours_max,size(vector_backoff,2));
    
    %matrix_results_collision_simulation_neighbour_backoff_global = zeros(number_of_simulation,no_neighbours_max,size(vector_backoff,2));
    
    %matrix_collision_sim_neighbour_backoff_global_per_station = zeros(number_of_simulation,no_neighbours_max,size(vector_backoff,2));
    %matrix_col_occured_sim_neighbour_backoff_global_per_station = zeros(number_of_simulation,no_neighbours_max,size(vector_backoff,2));
    %matrix_results_collision_avg_per_station = zeros(no_neighbours_max,size(vector_backoff,2),no_neighbours_max + 1);
    %matrix_results_counter_slots_global = zeros(number_of_simulation,no_neighbours_max,size(vector_backoff,2));
    %matrix_results_counter_round_global_packet_collided = zeros(number_of_simulation,size(vector_neighbours,2),size(vector_backoff,2));
    %matrix_results_counter_round_global_packet_delivered = zeros(number_of_simulation,size(vector_neighbours,2),size(vector_backoff,2));
    
    % Initialization for retries
    %matrix_results_retries_min = zeros(no_neighbours_max,size(vector_backoff,2));
    %matrix_results_retries_min_counter = zeros(no_neighbours_max,size(vector_backoff,2));
    %matrix_results_retries_max = zeros(no_neighbours_max,size(vector_backoff,2));
    %matrix_results_retries_max_counter = zeros(no_neighbours_max,size(vector_backoff,2));
    %matrix_results_retries_avg = zeros(no_neighbours_max,size(vector_backoff,2));
    
    % Initialization for Random-Generator
    seed_value = 1;
    func_sim_generator_random_set(seed_value);
    
    % Initialization for helpers
    %first_time_collision = zeros(no_neighbours_max,size(vector_backoff,2));
    %first_time_retries = zeros(no_neighbours_max,size(vector_backoff,2));
    activated = 1; %different simulation strategies (see options)
    if (activated == 1 || activated == 3 || activated == 4)
        matrix_results_counter_slots_global = zeros(number_of_simulation,size(vector_neighbours,2),size(vector_backoff,2));
        matrix_results_counter_round_global_packet_collided = zeros(number_of_simulation,size(vector_neighbours,2),size(vector_backoff,2));
        matrix_results_counter_round_global_packet_delivered = zeros(number_of_simulation,size(vector_neighbours,2),size(vector_backoff,2));
   elseif (activated == 2)
        matrix_results_counter_slots_global = zeros(number_of_simulation,size(vector_neighbours,2),1);
        matrix_results_counter_round_global_packet_collided = zeros(number_of_simulation,size(vector_neighbours,2),1);
        matrix_results_counter_round_global_packet_delivered = zeros(number_of_simulation,size(vector_neighbours,2),1);
    end
    % Simulation for different simulation-retries, backoff-window-sizes and
    % neighbours start here
    for no_sim=1:1:number_of_simulation
        for  no_backoff_window_size=1:1:size(vector_backoff,2)
            for no_of_neighbours=1:1:size(vector_neighbours,2)
                no_of_stations_current = vector_neighbours(1,no_of_neighbours) + 1;% number of neighbours + (one station more, myself)
                criterion_abort = -1;
                if (activated == 1 || activated == 3 || activated == 4)
                    vector_cw(1,1) = vector_backoff(1,no_backoff_window_size);
                    criterion_abort =   no_of_stations_current/ vector_cw(1,1); 
                elseif (activated == 2)
                    vector_cw = [15,31,63,127,255,511,1023];
                    criterion_abort = no_of_stations_current/ vector_cw(1,size(vector_cw,2)); 
                end
                %vector_cw(1,2) = vector_backoff(1,no_backoff_window_size);
                %criterion_abort =  no_of_neighbours/ vector_cw(1,1); 
                
                
                %criterion_abort== 0, does not exist, because CW-value >= number_of_neighbours
                %criterion_abort== 1, means, that 100% packet loss 
                if (criterion_abort > 0 && criterion_abort <= 1) 
                    %[counter_slots_global,packets_delivery_counter,packets_delivery_counter_global, counter_collision_global,retries_min_mean_neighbours,retries_max_mean_neighbours, retries_avg_mean_neighbours ] = func_backoff_calculation(vector_cw, no_of_stations_current,packet_delivery_limit);
                    %[counter_slots_global,packets_delivery_counter_global, counter_collision_global,retries_min,retries_max,retries_avg,retries_avg_counter,counter_retries_min_frequencies,counter_retries_max_frequencies ] = func_backoff_calculation(vector_cw, no_of_stations_current,packet_delivery_limit);
                    
                    %[counter_slots_global,packets_delivery_counter_global, counter_collision_global,vector_packets_delivered_per_station,vector_collision_occurred_per_station,retries_min,retries_max,retries_avg,retries_avg_counter,counter_retries_min_frequencies,counter_retries_max_frequencies ] = func_backoff_calculation(vector_cw,  no_of_stations_current,packet_delivery_limit);
                     % algo1 = feste Backoff für verschiedene Nachbarstationen Kollisionswkt, neu Würfeln ohne auf die Paketübertragung der anderen Stationen zu warten
                    % algo2 = Standardverfahren:= Nach jeder Kollision erhöhe Backoff-Fenstergröße und nehme Startwert, wenn Paketübertragung erfolgreich gewesen ist
                     if (activated == 1 || activated == 2)
                        [packets_delivery_counter_global, counter_collision_global,counter_slots_global] = func_backoff_calculation(vector_cw, no_of_stations_current);
                     elseif (activated == 3) % algo3 = feste Backoff für verschiedene Nachbarstationen Kollisionswkt, neu Würfeln und auf die Paketübertragung der anderen Stationen zu warten
                        [packets_delivery_counter_global, counter_collision_global,counter_slots_global]  = func_backoff_calculation_4(vector_cw, no_of_stations_current);
                     elseif (activated == 4) % klassisches Geburtstagsparadoxon
                        [packets_delivery_counter_global, counter_collision_global,counter_slots_global] = func_backoff_calculation_2(vector_cw, no_of_stations_current);
                     end
                     if (activated == 1 || activated == 3 || activated == 4)
                        matrix_results_counter_slots_global(no_sim,no_of_neighbours,no_backoff_window_size) = counter_slots_global;
                        matrix_results_counter_round_global_packet_delivered(no_sim,no_of_neighbours,no_backoff_window_size) = packets_delivery_counter_global;    
                    
                        %matrix_results_collision_simulation_neighbour_backoff_global(no_sim,no_of_neighbours,no_backoff_window_size) = packets_delivery_counter_global;
                        matrix_results_counter_round_global_packet_collided(no_sim,no_of_neighbours,no_backoff_window_size) = counter_collision_global;   
                     elseif (activated == 2 && no_backoff_window_size == 1)
                        matrix_results_counter_slots_global(no_sim,no_of_neighbours,no_backoff_window_size) = counter_slots_global;
                        matrix_results_counter_round_global_packet_delivered(no_sim,no_of_neighbours,no_backoff_window_size) = packets_delivery_counter_global;    
                    
                        %matrix_results_collision_simulation_neighbour_backoff_global(no_sim,no_of_neighbours,no_backoff_window_size) = packets_delivery_counter_global;
                        matrix_results_counter_round_global_packet_collided(no_sim,no_of_neighbours,no_backoff_window_size) = counter_collision_global;   
                     end
                    %matrix_collision_sim_neighbour_backoff_global_per_station(no_sim,no_of_neighbours,no_backoff_window_size) = sum(vector_packets_delivered_per_station,2);
                    %matrix_col_occured_sim_neighbour_backoff_global_per_station(no_sim,no_of_neighbours,no_backoff_window_size) = sum(vector_collision_occurred_per_station,2);
                    %    [collision_avg_global, vector_collision_avg_per_station] = func_statistics_calc_collisions( packets_delivery_counter_global,counter_collision_global,vector_packets_delivered_per_station,vector_collision_occurred_per_station);
                    
                    %matrix_results_collision_avg_global(no_of_neighbours,no_backoff_window_size) = matrix_results_collision_avg_global(no_of_neighbours,no_backoff_window_size) + collision_avg_global;
                    %matrix_results_collision_avg_per_station(no_of_neighbours,no_backoff_window_size) = sum(vector_collision_avg_per_station,2);
                    %matrix_results_collision_simulation_neighbour_backoff_global(no_sim,no_of_neighbours,no_backoff_window_size) = matrix_results_collision_simulation_neighbour_backoff_global(no_sim,no_of_neighbours,no_backoff_window_size) +
                    %matrix_results_counter_collision_simulation_neighbour_backoff_global(no_sim,no_of_neighbours,no_backoff_window_size) = matrix_results_counter_collision_simulation_neighbour_backoff_global(no_sim,no_of_neighbours,no_backoff_window_size) +    
                    
                    
                    %matrix_results_packets_delivery_counter(no_of_neighbours,no_backoff_window_size) = matrix_results_packets_delivery_counter(no_of_neighbours,no_backoff_window_size) + packets_delivery_counter;
                                        
                    %[first_time,minimal, counter_min,maximal,counter_max ] = func_statistics_calc(first_time_collision(no_of_neighbours,no_backoff_window_size),  matrix_results_collision_min(no_of_neighbours,no_backoff_window_size), matrix_results_collision_min_counter(no_of_neighbours,no_backoff_window_size), matrix_results_collision_max(no_of_neighbours,no_backoff_window_size),matrix_results_collision_max_counter(no_of_neighbours,no_backoff_window_size), matrix_results_collision_avg(no_of_neighbours,no_backoff_window_size),no_sim, counter_collision_global);
                    %[first_time,minimal, counter_min,maximal,counter_max,avg, counter_avg] = func_statistics_calc(first_time_collision(no_of_neighbours,no_backoff_window_size), matrix_results_collision_min(no_of_neighbours,no_backoff_window_size), matrix_results_collision_min_counter(no_of_neighbours,no_backoff_window_size), matrix_results_collision_max(no_of_neighbours,no_backoff_window_size), matrix_results_collision_max_counter(no_of_neighbours,no_backoff_window_size), matrix_results_collision_avg(no_of_neighbours,no_backoff_window_size),no_sim,counter_collision_global);
                    
                    % Statistics for collisions have to be saved
                    %matrix_results_collision_min(no_of_neighbours,no_backoff_window_size) = minimal;
                    %matrix_results_collision_min_counter(no_of_neighbours,no_backoff_window_size) = counter_min;
                    %matrix_results_collision_max(no_of_neighbours,no_backoff_window_size) = maximal;
                    %matrix_results_collision_max_counter(no_of_neighbours,no_backoff_window_size) = counter_max;
                    
                    %first_time_collision(no_of_neighbours,no_backoff_window_size) = first_time;
                    

                    
                    % Retries calculations have to be saved
                    %[retries_min_mean_neighbours,retries_max_mean_neighbours, retries_avg_mean_neighbours] = func_statistics_calc_retries(retries_min,retries_max,retries_avg,retries_avg_counter,counter_retries_min_frequencies,counter_retries_max_frequencies);
                    %if (first_time_retries(no_of_neighbours,no_backoff_window_size) == 0)
                    %    matrix_results_retries_min(no_of_neighbours,no_backoff_window_size) = retries_min_mean_neighbours;
                    %    matrix_results_retries_min_counter(no_of_neighbours,no_backoff_window_size) = 1;
                    %    matrix_results_retries_max(no_of_neighbours,no_backoff_window_size) = retries_max_mean_neighbours;
                    %    matrix_results_retries_max_counter(no_of_neighbours,no_backoff_window_size) = 1;
                    %    matrix_results_retries_avg(no_of_neighbours,no_backoff_window_size) = retries_avg_mean_neighbours;
                    %    first_time_retries(no_of_neighbours,no_backoff_window_size) = 1;
                    %else
                    %    if (retries_min_mean_neighbours < matrix_results_retries_min(no_of_neighbours,no_backoff_window_size))
                    %        matrix_results_retries_min(no_of_neighbours,no_backoff_window_size) = retries_min_mean_neighbours;
                    %        matrix_results_retries_min_counter(no_of_neighbours,no_backoff_window_size) = 1;
                    %    elseif (retries_min_mean_neighbours == matrix_results_retries_min(no_of_neighbours,no_backoff_window_size))
                    %        matrix_results_retries_min_counter(no_of_neighbours,no_backoff_window_size) = matrix_results_retries_min_counter(no_of_neighbours,no_backoff_window_size) + 1;
                    %    end
                    %    if (retries_max_mean_neighbours > matrix_results_retries_max(no_of_neighbours,no_backoff_window_size))
                    %        matrix_results_retries_max(no_of_neighbours,no_backoff_window_size) = retries_max_mean_neighbours;
                    %        matrix_results_retries_max_counter(no_of_neighbours,no_backoff_window_size) = 1;
                    %    elseif (retries_max_mean_neighbours == matrix_results_retries_max(no_of_neighbours,no_backoff_window_size))
                    %        matrix_results_retries_max_counter(no_of_neighbours,no_backoff_window_size) = matrix_results_retries_max_counter(no_of_neighbours,no_backoff_window_size) + 1;
                    %    end
                     %   matrix_results_retries_avg(no_of_neighbours,no_backoff_window_size) = matrix_results_retries_avg(no_of_neighbours,no_backoff_window_size) + retries_avg_mean_neighbours;
                    %end
                end
            end
        end
    end
    %matrix_results_collision_avg = matrix_results_collision_avg / number_of_simulation;
    %matrix_results_retries_avg = matrix_results_retries_avg / number_of_simulation;
end

