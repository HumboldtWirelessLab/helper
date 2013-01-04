function [minimum] = func_simulation_search_4_minimum(vector_backoff_random_current)
    minimum = -1;
    for i=1:1:size(vector_backoff_random_current,2)
        if(vector_backoff_random_current(1,i) >= 0 && minimum == -1)
            minimum = vector_backoff_random_current(1,i);
        elseif (vector_backoff_random_current(1,i) >= 0 && vector_backoff_random_current(1,i) < minimum)
            minimum = vector_backoff_random_current(1,i);
        end
    end
end

