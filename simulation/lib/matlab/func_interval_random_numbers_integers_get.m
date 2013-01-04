function [vector_random_numbers] = func_interval_random_numbers_integers_get(value_min,value_max,no_random_numbers,option)
    if (option == 1)
        vector_random_numbers = round(value_max + (value_min-value_max).*rand(no_random_numbers,1))';
    elseif(option == 2)
        vector_random_numbers = randi([value_min,value_max],1,no_random_numbers);
    else
        vector_random_numbers = zeros(1,no_random_numbers);
    end
end

