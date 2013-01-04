function [first_time,minimal, counter_min,maximal,counter_max,avg, counter_avg] = func_statistics_calc(first_time, min_value, counter_min_value, max_value, counter_max_value, avg_value,counter_avg_value, current_value)
    minimal = 0;
    counter_min = 0; 
    maximal = 0;
    counter_max = 0;
    if (first_time == 0)
                
        minimal = current_value;
        counter_min = 1;
                
        maximal = current_value;
        counter_max = 1;
                
        avg = avg_value + current_value;
        counter_avg = counter_avg_value + 1;
                           
        first_time = 1;
    else
        if (current_value < min_value)
            minimal = current_value;
            counter_min = 1;
         elseif (current_value == min_value)
            counter_min = counter_min_value + 1;
        end
        if (current_value > max_value)
            maximal = current_value;
            counter_max = 1;
        elseif (current_value == max_value)
            counter_max = counter_max_value + 1;
        end
        avg = avg_value + current_value;
        counter_avg = counter_avg_value + 1;
    end
    
        

end

