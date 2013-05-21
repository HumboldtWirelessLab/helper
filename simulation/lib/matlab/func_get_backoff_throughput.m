function [ vector_backoff_new,matrix_2d] = func_get_backoff_throughput(rate,matrix_backoff_3D,matrix_throughput_3D)
    [matrix_backoff] = func_convert_matrix_3D_2_2D(matrix_backoff_3D,rate);
    vector_backoff_new = matrix_backoff(rate,:);
    [matrix_2d] = func_convert_matrix_3D_2_2D(matrix_throughput_3D,rate);
end

