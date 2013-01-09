function [vector_backoff_random_current,vector_collision_occurred_per_station,vector_packets_delivered_per_station,retries,counter_retries,retries_current,retries_min,retries_max,counter_retries_min_frequencies,counter_retries_max_frequencies,retries_avg,retries_avg_counter,retries_min_first_time] = func_simulation_collision_statics_calc(vector_backoff_random_current,option,counter_collision,vector_collision_occurred_per_station,vector_packets_delivered_per_station,retries,counter_retries,retries_current,retries_min,retries_max,counter_retries_min_frequencies,counter_retries_max_frequencies,retries_avg,retries_avg_counter,retries_min_first_time,vector_cw)
    %Search for each station
    for j=1:1:size(vector_backoff_random_current,2)
        %Station are sending its frame
        if (vector_backoff_random_current(1,j) == 0)
            %If collisions have occured
            if (counter_collision > 1)
                vector_collision_occurred_per_station(1,j) = vector_collision_occurred_per_station(1,j) + 1;
                retries(counter_retries,j) = retries(counter_retries,j) + 1;
                retries_current(1,j) = retries_current(1,j) + 1;
                if (retries(counter_retries,j) >= size(vector_cw,2))
                    retries(counter_retries,j) = size(vector_cw,2)- 1;
                end
            %If there are not any collision => frame transmission was succesful    
            elseif (counter_collision == 1 )
                vector_packets_delivered_per_station(1,j) = vector_packets_delivered_per_station(1,j) + 1;
                %packets_delivery_counter_global = packets_delivery_counter_global + 1;
                if(retries(counter_retries,j) > 0)
                    retries(counter_retries,j) = 0;
                end
                if (retries_min_first_time(1,j) == 0)
                    retries_min(1,j) = retries_current(1,j);
                    counter_retries_min_frequencies(1,j) = 1;
                    retries_max(1,j) = retries_current(1,j);
                    counter_retries_max_frequencies(1,j) = 1;
                    retries_avg(1,j) = retries_current(1,j);
                    retries_avg_counter(1,j) = retries_avg_counter(1,j) + 1;
                    retries_min_first_time(1,j) = 1;
                else
                    if (retries_current(1,j) < retries_min(1,j))
                        retries_min(1,j) = retries_current(1,j);
                        counter_retries_min_frequencies(1,j) = 1;
                    elseif (retries_current(1,j) == retries_min(1,j))
                        counter_retries_min_frequencies(1,j) = counter_retries_min_frequencies(1,j) + 1;
                    end
                    if (retries_current(1,j) > retries_max(1,j))
                        retries_max(1,j) = retries_current(1,j);
                        counter_retries_max_frequencies(1,j) = 1;
                    elseif (retries_current(1,j) == retries_max(1,j))
                        counter_retries_max_frequencies(1,j) = counter_retries_max_frequencies(1,j) + 1;
                    end
                    retries_avg(1,j) = retries_avg(1,j) + retries_current(1,j);
                    retries_avg_counter(1,j) = retries_avg_counter(1,j) + 1;
                end
            end
            vector_backoff_random_current(1,j) = func_interval_random_numbers_integers_get(0,vector_cw(1,1),1,option);
        end
    end
end

