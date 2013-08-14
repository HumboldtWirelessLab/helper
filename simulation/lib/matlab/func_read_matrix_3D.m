function [matrix_new] = func_read_matrix_3D(filename,size_dim1,size_dim2,size_dim3)
    fid = fopen(filename,'r');
    matrix = fread(fid);
    fclose(fid);
    matrix_new = zeros(size_dim1,size_dim2,size_dim3);
    counter = 1;
    counter_2 = 1;
    %counter_total = size_dim1 * size_dim2 * size_dim3;
    vector_start = 1:size_dim1*size_dim2:size(matrix,1);
    vector_end = size_dim1*size_dim2:size_dim1*size_dim2:size(matrix,1);
    for i=1:1:size(vector_start,2)
            for j = vector_start(1,i):1:vector_end(1,i)
                %if(vector_start(1,i) <= j && vector_end(1,i) >= j)
                    matrix_new(counter,counter_2,i) = matrix(j,1);
                    counter = counter + 1;
                    if(counter > 2)
                        counter_2 = counter_2 + 1;
                        counter = 1;
                    end
                %end
            end
        counter = 1;
        counter_2 = 1;
    end
end


