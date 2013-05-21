function [error_packet_losss_series] = func_error_diff_calc(matrix_1,matrix_2,vector_columns_max)
    error_packet_losss_series = zeros(size(vector_columns_max,1),max(vector_columns_max));
    for t = 1:1:size(vector_columns_max,1)
            [ vector_shorten_1] = func_test_vector_shorten_2(matrix_1(t,:), vector_columns_max(t,1));
            [ vector_shorten_2] = func_test_vector_shorten_2(matrix_2(t,:), vector_columns_max(t,1));
            error_calc = vector_shorten_1 - vector_shorten_2;
            error_packet_losss_series(t,1:1:vector_columns_max(t,1)) = sqrt(error_calc(1:1:vector_columns_max(t,1),1).^2);
    end
end

