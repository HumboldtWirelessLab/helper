function [ vector_shorten ] = func_birthday_problem_vector_shorten_2(vector,counter_max)
    vector_shorten = zeros(counter_max,1);
    for i = 1:1:counter_max
        vector_shorten(i,1) = vector(i,1);
    end
end
