function [packets_delivery_counter_global, counter_collision_global,counter_slots_global] = func_backoff_calculation_2(vector_cw, number_of_stations)
    counter_slots_global = 0;
    packets_delivery_counter_global = 0;
    counter_collision_global = 0;
    
    vector_station_has_packet_transmitted = zeros(1,number_of_stations);
    vector_collision_occurred_per_station = zeros(1,number_of_stations);
    vector_packets_delivered_per_station = zeros(1,number_of_stations);
    % Simualtion of collisions start here
    packet_delivery_limit = number_of_stations * 100;
    while (packets_delivery_counter_global < packet_delivery_limit)
        vector_backoff_random_current = randi([0,vector_cw(1,1)],1,number_of_stations);
        %for i=1:1:number_of_stations
        while (sum(vector_station_has_packet_transmitted) < number_of_stations)
            %Search for minimum Backoff 
            minimum = min(vector_backoff_random_current);
            % Calculate Backoff and count Slots
            if(minimum > 0)
                vector_backoff_random_current = vector_backoff_random_current -  minimum;
                counter_slots_global = counter_slots_global + minimum;
            end
            % Search for collisions
            counter_collision = func_simulation_search_4_collision(vector_backoff_random_current);
            [vector_backoff_random_current,vector_collision_occurred_per_station,vector_packets_delivered_per_station,vector_station_has_packet_transmitted] = func_simulation_stats_per_station_get_2(vector_backoff_random_current,vector_collision_occurred_per_station,vector_packets_delivered_per_station,vector_cw,counter_collision,vector_station_has_packet_transmitted);
            %If there are collisions count it global as one collision
        end
        if(sum(vector_packets_delivered_per_station) == number_of_stations)
            packets_delivery_counter_global = packets_delivery_counter_global + 1;
        else
            counter_collision_global = counter_collision_global + 1;
        end
        vector_station_has_packet_transmitted(vector_station_has_packet_transmitted > 0) = 0;
        vector_collision_occurred_per_station(vector_collision_occurred_per_station > 0) = 0;
        vector_packets_delivered_per_station(vector_packets_delivered_per_station > 0) = 0;
    end
end



