function [vector] = func_find_for_throughput_highest_2(matrix_2_search, vector_backoff_window_size_for_tmt_max_per_neighbour)
    number_of_neighbours_max = size(vector_backoff_window_size_for_tmt_max_per_neighbour,1);
    vector = zeros(number_of_neighbours_max,1);
    for i = 1:1:number_of_neighbours_max
        if (vector_backoff_window_size_for_tmt_max_per_neighbour(i,1) > 0)
            vector(i,1) = matrix_2_search(i,(vector_backoff_window_size_for_tmt_max_per_neighbour(i,1)-1));
        end
    end
end