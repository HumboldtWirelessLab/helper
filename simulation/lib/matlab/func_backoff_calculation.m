function [packets_delivery_counter_global, counter_collision_global,counter_slots_global]  = func_backoff_calculation(vector_cw, number_of_stations)
    %Initialization 
    %init for collision calculation
    counter_slots_global = 0;
    packets_delivery_counter_global = 0;
    counter_collision_global = 0;
    packet_delivery_limit = number_of_stations * 100;
    vector_packets_delivered_per_station = zeros(1,number_of_stations);   
    vector_collision_occurred_per_station = zeros(1,number_of_stations);
    %init random backoff calculation
    option_random_backoff_calculation = 2;
    counter_cw_current = 1;
    vector_backoff_random_current = func_interval_random_numbers_integers_get(0,vector_cw(1,counter_cw_current),number_of_stations,option_random_backoff_calculation);
    
    % Simualtion of collisions start here
    while (packets_delivery_counter_global < packet_delivery_limit)
        %Search for minimum Backoff and 
        [minimum] = func_simulation_search_4_minimum(vector_backoff_random_current);
        % Calculate Backoff and count Slots
        if(minimum > 0)
            vector_backoff_random_current = vector_backoff_random_current -  minimum;
            counter_slots_global = counter_slots_global + minimum;
        end
        % Search for collisions
        counter_collision = func_simulation_search_4_collision(vector_backoff_random_current);
        %If there are collisions count it global as one collision
        if(counter_collision > 1)
            counter_collision_global = counter_collision_global + 1;
            counter_cw_current = counter_cw_current + 1;
            if (counter_cw_current > size(vector_cw,2)) 
                counter_cw_current = size(vector_cw,2);
            end
        elseif (counter_collision == 1)
            packets_delivery_counter_global = packets_delivery_counter_global + 1;
            counter_cw_current = 1;
        end
        [vector_backoff_random_current,vector_collision_occurred_per_station,vector_packets_delivered_per_station] = func_simulation_stats_per_station_standard_get(vector_backoff_random_current,vector_collision_occurred_per_station,vector_packets_delivered_per_station,vector_cw,counter_collision,option_random_backoff_calculation,counter_cw_current);
    end
end

