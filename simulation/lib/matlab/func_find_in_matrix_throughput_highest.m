function [matrix_result] = func_find_in_matrix_throughput_highest(matrix_2_search, matrix_backoff)
    matrix_result = zeros(size(matrix_backoff,1),size(matrix_backoff,2));
    for i= 1:1:size(matrix_backoff,2)
         pos_indices = find(matrix_backoff(:,i) == -1,1);
        if (isempty(pos_indices))
            pos_indices = size(matrix_backoff,1);
        end
        [vectorair] = func_find_for_throughput_highest_3(matrix_2_search, matrix_backoff(1:1:pos_indices,i))';
        matrix_result(1:1:size(vectorair,2),i) = vectorair(1,1:1:size(vectorair,2));
    end
end

