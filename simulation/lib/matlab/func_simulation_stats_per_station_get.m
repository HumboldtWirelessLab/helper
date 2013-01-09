function [vector_backoff_random_current_2,vector_collision_occurred_per_station_2,vector_packets_delivered_per_station_2,vector_station_has_packet_transmitted_2] = func_simulation_stats_per_station_get(vector_backoff_random_current,vector_collision_occurred_per_station,vector_packets_delivered_per_station,vector_cw,counter_collision,vector_station_has_packet_transmitted,option)
    %Search for each station
    for j=1:1:size(vector_backoff_random_current,2)
        %Station are sending its frame
        if (vector_backoff_random_current(1,j) == 0)
            % Test for birthday_paradoxon
            %if (vector_station_has_packet_transmitted(1,j) == 0)
                %If collisions have occured
                if (counter_collision > 1)
                    vector_collision_occurred_per_station(1,j) = vector_collision_occurred_per_station(1,j) + 1;
                %If there are not any collision => frame transmission was succesful    
                elseif (counter_collision == 1 )
                    vector_packets_delivered_per_station(1,j) = vector_packets_delivered_per_station(1,j) + 1;
                end
                %vector_backoff_random_current(1,j) = func_interval_random_numbers_integers_get(0,vector_cw(1,1),1,option);
                vector_backoff_random_current(1,j) = vector_cw(1,1) + 2; % do backoff out of range
                vector_station_has_packet_transmitted(1,j) = 1;
            %end
        elseif (vector_station_has_packet_transmitted(1,j) > 0) %test for birthday_paradoxn
            vector_backoff_random_current(1,j) = vector_cw(1,1) + 2; % do backoff out of range
        end
    end
    vector_backoff_random_current_2 = vector_backoff_random_current;
    vector_collision_occurred_per_station_2 = vector_collision_occurred_per_station;
    vector_packets_delivered_per_station_2 = vector_packets_delivered_per_station;
    vector_station_has_packet_transmitted_2 = vector_station_has_packet_transmitted;
end

