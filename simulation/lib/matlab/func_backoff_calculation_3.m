%function [counter_slots_global,packets_delivery_counter_global, counter_collision_global,vector_packets_delivered_per_station,vector_collision_occurred_per_station,retries_min,retries_max,retries_avg,retries_avg_counter,counter_retries_min_frequencies,counter_retries_max_frequencies ] = func_backoff_calculation(vector_cw, number_of_stations)
function [packets_delivery_counter_global, counter_collision_global,counter_slots_global]  = func_backoff_calculation_3(vector_cw, number_of_stations)

    %Initialization
    
    %init for collision calculation
    counter_slots_global = 0;
    packets_delivery_counter_global = 0;
    counter_collision_global = 0;
    packet_delivery_limit = number_of_stations * 100;
    vector_packets_delivered_per_station = zeros(1,number_of_stations);   
    vector_collision_occurred_per_station = zeros(1,number_of_stations);
    
    % init for retries calculation
    retries = zeros(1,number_of_stations);
    retries_max = zeros(1,number_of_stations);
    retries_min = zeros(1,number_of_stations);
    retries_min_first_time = zeros(1,number_of_stations);
    retries_avg = zeros(1,number_of_stations);
    retries_avg_counter = zeros(1,number_of_stations);
    counter_retries_min_frequencies = zeros(1,number_of_stations);
    counter_retries_max_frequencies = zeros(1,number_of_stations);
    retries_current = zeros(1,number_of_stations);
    counter_retries = 1;
    
    %init random backoff calculation
    option_random_backoff_calculation = 2;
    option_standard = 3;
    option_termination = 1;
    vector_backoff_random_current = func_interval_random_numbers_integers_get(0,vector_cw(1,1),number_of_stations,option_random_backoff_calculation);
    vector_station_has_packet_transmitted = zeros(1,number_of_stations);
    %counter_backoff_random_row = 1;    
    %backoff_random = zeros(1,size(vector_backoff_random_current,2));
    %for z=1:1:size(backoff_random,2)
    %    backoff_random(counter_backoff_random_row,z) = vector_backoff_random_current(1,z);
    %end
    criterion_termination = 1;
    % Simualtion of collisions start here
    while (criterion_termination)

        %Search for minimum Backoff and 
        [minimum] = func_simulation_search_4_minimum(vector_backoff_random_current);
        % Calculate Backoff and count Slots
        if(minimum > 0)
            vector_backoff_random_current = vector_backoff_random_current -  minimum;
            counter_slots_global = counter_slots_global + minimum;
        %elseif (minimum == 0)
        %    counter_slots_global = counter_slots_global + 1;
        end
        % Search for collisions
        counter_collision = func_simulation_search_4_collision(vector_backoff_random_current);
        %If there are collisions count it global as one collision
        if(counter_collision > 1)
            counter_collision_global = counter_collision_global + 1;
        elseif (counter_collision == 1)
            packets_delivery_counter_global = packets_delivery_counter_global + 1;
        end

%        [vector_backoff_random_current,vector_collision_occurred_per_station,vector_packets_delivered_per_station,packets_delivery_counter_global,retries,counter_retries,retries_current,retries_min,retries_max,counter_retries_min_frequencies,counter_retries_max_frequencies,retries_avg,retries_avg_counter,retries_min_first_time] = func_simulation_collision_statics_calc(vector_backoff_random_current,option,counter_collision,vector_collision_occurred_per_station,vector_packets_delivered_per_station,packets_delivery_counter_global,retries,counter_retries,retries_current,retries_min,retries_max,counter_retries_min_frequencies,counter_retries_max_frequencies,retries_avg,retries_avg_counter,retries_min_first_time,vector_cw);
        %[vector_backoff_random_current,vector_collision_occurred_per_station,vector_packets_delivered_per_station] = func_simulation_stats_per_station_get(vector_backoff_random_current,vector_collision_occurred_per_station,vector_packets_delivered_per_station,option);
        if (option_standard == 1)
            [vector_backoff_random_current,vector_collision_occurred_per_station,vector_packets_delivered_per_station] = func_simulation_stats_per_station_standard_get(vector_backoff_random_current,vector_collision_occurred_per_station,vector_packets_delivered_per_station,vector_cw,counter_collision,option_random_backoff_calculation);
        elseif (option_standard == 2)
            [vector_backoff_random_current,vector_collision_occurred_per_station,vector_packets_delivered_per_station,vector_station_has_packet_transmitted] = func_simulation_stats_per_station_get(vector_backoff_random_current,vector_collision_occurred_per_station,vector_packets_delivered_per_station,vector_cw,counter_collision,vector_station_has_packet_transmitted,option_random_backoff_calculation);
            counter_transmitted = 0;
            for i=1:1:size(vector_station_has_packet_transmitted,2) %search for transmitted stations
                if (vector_station_has_packet_transmitted(1,i) == 1)
                    counter_transmitted = counter_transmitted + 1;
                end
            end
            if (counter_transmitted == size(vector_station_has_packet_transmitted,2))
                vector_backoff_random_current = func_interval_random_numbers_integers_get(0,vector_cw(1,1),number_of_stations,option_random_backoff_calculation);
                vector_station_has_packet_transmitted = zeros(1,number_of_stations); 
            end
        elseif (option_standard == 3)
            vector_backoff_random_current = func_interval_random_numbers_integers_get(0,vector_cw(1,1),number_of_stations,option_random_backoff_calculation);
        end
        if (option_termination == 1)
            [criterion_termination] = func_backoff_calculation_terminate_global(packets_delivery_counter_global,packet_delivery_limit);
        else
            [criterion_termination] = func_backoff_calculation_terminate_per_station(vector_packets_delivered_per_station,packet_delivery_limit);
        end
        %counter_collision = 0;
        %counter_backoff_random_row = counter_backoff_random_row + 1;
        %for z=1:1:size(vector_backoff_random_current,2)
        %    backoff_random(counter_backoff_random_row,z) = vector_backoff_random_current(1,z);
        %end
    end
end

