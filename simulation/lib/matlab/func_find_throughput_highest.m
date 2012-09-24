function [ vector_tmt_max_per_neighbour, vector_backoff_window_size_for_tmt_max_per_neighbour ] = func_find_throughput_highest(matrix_air_capacity)
    [number_of_neighbours_max, number_of_backoff_window_size_max] = size(matrix_air_capacity);
    vector_tmt_max_per_neighbour = zeros(number_of_neighbours_max,1);
    vector_backoff_window_size_for_tmt_max_per_neighbour = zeros(number_of_neighbours_max,1);
    for i=1:1:number_of_neighbours_max 
        for j=1:1:number_of_backoff_window_size_max
            if ((vector_tmt_max_per_neighbour(i,1) == 0) && (matrix_air_capacity(i,j) > 0))
                vector_tmt_max_per_neighbour(i,1) = matrix_air_capacity(i,j);
                vector_backoff_window_size_for_tmt_max_per_neighbour(i,1) = j + 1;
                
            elseif (matrix_air_capacity(i,j) > vector_tmt_max_per_neighbour(i,1))
                vector_tmt_max_per_neighbour(i,1) = matrix_air_capacity(i,j);
                vector_backoff_window_size_for_tmt_max_per_neighbour(i,1) = j + 1;
            end
        end
    end
end

