function [ vector_shorten] = func_test_vector_shorten_2(vector, new_max_size)
    if (size(vector,2) > new_max_size)
        %no_neighbours_max = max(counter_of_successful_conditions);
        %vector_birthday_problem_approximation_neighbours = 1:1:no_neighbours_current;
        [ vector_shorten ] = func_birthday_problem_vector_shorten(vector,new_max_size);
    else
        vector_shorten = vector';
    end
end

