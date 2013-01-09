function [counter_collision] = func_simulation_search_4_collision(vector_backoff_random_current)
    counter_collision = 0;
    for j=1:1:size(vector_backoff_random_current,2)
        if (vector_backoff_random_current(1,j) == 0)
            counter_collision = counter_collision + 1;
        end
    end
end

