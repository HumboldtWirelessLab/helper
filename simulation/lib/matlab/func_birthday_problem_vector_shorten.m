function [ vector_shorten ] = func_birthday_problem_vector_shorten(vector,counter_max)
    vector_shorten = zeros(counter_max,1);
    for i = 1:1:counter_max
        vector_shorten(i,1) = vector(1,i);
    end
end

