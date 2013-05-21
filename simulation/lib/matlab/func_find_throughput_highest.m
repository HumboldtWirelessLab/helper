function [vector_tmt_air_capacity_max, vector_tmt_index_backoff_max] = func_find_throughput_highest(matrix_air_capacity)
    vector_tmt_air_capacity_max = zeros(size(matrix_air_capacity,1),1);
    vector_tmt_index_backoff_max = zeros(size(matrix_air_capacity,1),1);
    for i=1:1:size(matrix_air_capacity,1) 
        for j=1:1:size(matrix_air_capacity,2)
            if ((vector_tmt_air_capacity_max(i,1) == 0) && (matrix_air_capacity(i,j) > 0))
                vector_tmt_air_capacity_max(i,1) = matrix_air_capacity(i,j);
                %vector_tmt_index_column(i,1) = j + 1;
                vector_tmt_index_backoff_max(i,1) = j;
            elseif (matrix_air_capacity(i,j) > vector_tmt_air_capacity_max(i,1))
                vector_tmt_air_capacity_max(i,1) = matrix_air_capacity(i,j);
                %vector_tmt_index_column(i,1) = j + 1;
                vector_tmt_index_backoff_max(i,1) = j;
            end
        end
    end
end

