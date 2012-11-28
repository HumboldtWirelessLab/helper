function [counter_slots_global,packets_delivery_counter,packets_delivery_counter_global, counter_collision_global,retries_min_mean_neighbours,retries_max_mean_neighbours, retries_avg_mean_neighbours ] = func_backoff_calculation(vector_cw, number_of_stations,packet_delivery_limit, seed_value)

if (seed_value >= 0)
    %see http://blogs.mathworks.com/loren/2008/11/05/new-ways-with-random-numbers-part-i/
    %see http://blogs.mathworks.com/loren/2008/11/13/new-ways-with-random-numbers-part-ii/
    stream0 = RandStream('mt19937ar','Seed',seed_value); % Mersenne Twister, change seed value 
    RandStream.setDefaultStream(stream0);
elseif (seed_value == -1)
    rng shuffle % creates a different seed each time; see http://www.mathworks.de/help/techdoc/math/bs1qb_i.html
end

counter_backoff_random_row = 1;
%counter_backoff_random_output_row = 1;
counter_collision_global = 0;
packets_delivered = zeros(1,number_of_stations);
collision_occurred = zeros(1,number_of_stations);
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
packets_delivery_counter = 0;
counter_slots_global = 0;
backoff_random = int32((vector_cw(1,1)-1)* rand(1,number_of_stations));
vector_backoff_random_current = zeros(1,size(backoff_random,2));
for z=1:1:size(backoff_random,2)
    vector_backoff_random_current(1,z) = backoff_random(counter_backoff_random_row,z);
end

while (packets_delivery_counter < packet_delivery_limit)

minimum = -1;
for i=1:1:size(vector_backoff_random_current,2)
    if(vector_backoff_random_current(1,i) >= 0 && minimum == -1)
        minimum = vector_backoff_random_current(1,i);
    elseif (vector_backoff_random_current(1,i) >= 0 && vector_backoff_random_current(1,i) < minimum)
        minimum = vector_backoff_random_current(1,i);
    end
end


if(minimum >= 0)
vector_backoff_random_current = vector_backoff_random_current -  minimum;
counter_slots_global = counter_slots_global + minimum;
end

counter_collision = 0;
for j=1:1:size(vector_backoff_random_current,2)
        if (vector_backoff_random_current(1,j) == 0)
            counter_collision = counter_collision + 1;
        end
end
if(counter_collision > 1)
    counter_collision_global = counter_collision_global + 1;
    
end

%for z=1:1:size(vector_backoff_random_current,2)
 %   backoff_random_output(counter_backoff_random_output_row,z) =  vector_backoff_random_current(1,z);
%end
%counter_backoff_random_output_row = counter_backoff_random_output_row +1;
for j=1:1:size(vector_backoff_random_current,2)
    if (vector_backoff_random_current(1,j) == 0)
        if (counter_collision > 1)
        collision_occurred(1,j) = collision_occurred(1,j) + 1;
        %if(retries_counter_on == 1)
            retries(counter_retries,j) = retries(counter_retries,j) + 1;
            retries_current(1,j) = retries_current(1,j) + 1;
            if (retries(counter_retries,j) >= size(vector_cw,2))
                retries(counter_retries,j) = size(vector_cw,2)- 1;
            end
        %end
        %vector_backoff_random_current(1,j) = floor( vector_cw(1,retries(counter_retries,j)+1)*rand(1,1));
        
        elseif (counter_collision == 1 )
            packets_delivered(1,j) = packets_delivered(1,j) + 1;
            packets_delivery_counter = packets_delivery_counter + 1;
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
        
            %if (retries_current(counter_retries,j) > 0)
             %   if (retries_current(counter_retries,j) >= retries_max(counter_retries,j))
              %      retries_max(counter_retries,j) = retries_current(counter_retries,j);
               %     counter_retries_max_frequencies = 1;
               % end
               % retries_avg(counter_retries,j) = retries_avg(counter_retries,j) + retries_current(counter_retries,j);
            %end
        end
        %if
        %vector_backoff_random_current(1,j) = floor( vector_cw(1,retries(counter_retries,j)+1)*rand(1,1));
     vector_backoff_random_current(1,j) =int32(( vector_cw(1,retries(counter_retries,j)+1)-1)*rand(1,1));    
    end
   
end
counter_backoff_random_row = counter_backoff_random_row + 1;
%counter_retries = counter_retries + 1; 
for z=1:1:size(vector_backoff_random_current,2)
    backoff_random(counter_backoff_random_row,z) = vector_backoff_random_current(1,z);
    %retries(counter_retries,z) = retries(counter_retries-1,z);
end
%backoff_random(counter_backoff_random_row,:) =  vector_backoff_random_current(1,:);

%retries(counter_retries,:) = retries(counter_retries-1,:);
end

packets_delivery_counter_global = sum(packets_delivery_counter,2);
retries_min_mean_neighbours = mean(retries_min);
%counter_retries_min_frequencies;
retries_max_mean_neighbours = mean(retries_max);
%counter_retries_max_frequencies 
retries_avg_mean = zeros(1,size(retries_avg,2));
for r = 1:1:size(retries_avg,2)
    retries_avg_mean(1,r) = retries_avg(1,r) / retries_avg_counter(1,r);
end
retries_avg_mean_neighbours = mean(retries_avg_mean);

