function [collision_avg_global, vector_collision_avg_per_station] = func_statistics_calc_collisions( packets_delivery_counter_global,counter_collision_global,vector_packets_delivered_per_station,vector_collision_occurred_per_station)
    collision_avg_global = counter_collision_global / (counter_collision_global + packets_delivery_counter_global);
    
    vector_collision_avg_per_station = zeros(1,size(vector_packets_delivered_per_station,2));
    for i = 1:1:size(vector_collision_avg_per_station,2)
        vector_collision_avg_per_station(1,i) = vector_collision_occurred_per_station(1,i) / (vector_packets_delivered_per_station(1,i) + vector_collision_occurred_per_station(1,i));
    end

end

%    minimal = 0;
%    counter_min = 0; 
%    maximal = 0;
%    counter_max = 0;
%    if (first_time == 0)
%                
%        minimal = current_value;
%        counter_min = 1;
%                
%        maximal = current_value;
%        counter_max = 1;
%                
%        avg = avg_value + current_value;
%        counter_avg = counter_avg_value + 1;
%                           
%        first_time = 1;
%    else
%        if (current_value < min_value)
%            minimal = current_value;
%            counter_min = 1;
%         elseif (current_value == min_value)
%            counter_min = counter_min_value + 1;
%        end
%        if (current_value > max_value)
%            maximal = current_value;
%            counter_max = 1;
%        elseif (current_value == max_value)
%            counter_max = counter_max_value + 1;
%        end
%        avg = avg_value + current_value;
%        counter_avg = counter_avg_value + 1;
%    end