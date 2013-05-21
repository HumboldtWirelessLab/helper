function [ str_2_write ] = func_matrix_3D_2_c_plusplus(name, matrix_tmt_backoff_3D )
str_2_write = sprintf('static const uint32_t _backoff_matrix_tmt_%s_3D[%d][%d][%d]={',name,size(matrix_tmt_backoff_3D,1),size(matrix_tmt_backoff_3D,2),size(matrix_tmt_backoff_3D,3));
for z = 1:1:size(matrix_tmt_backoff_3D,1)
    str_2_write = sprintf('%s{',str_2_write);
    for i = 1:1:size(matrix_tmt_backoff_3D,2)
        str_2_write = sprintf('%s{',str_2_write);
        for j = 1:1:size(matrix_tmt_backoff_3D,3)
            if (j == 1)
                str_2_write = sprintf('%s%d,',str_2_write,matrix_tmt_backoff_3D(z,i,j));
            elseif (j == size(matrix_tmt_backoff_3D,3) && i ~= size(matrix_tmt_backoff_3D,2))
                str_2_write = sprintf('%s%d},',str_2_write,matrix_tmt_backoff_3D(z,i,j));
            elseif (j == size(matrix_tmt_backoff_3D,3) && i == size(matrix_tmt_backoff_3D,2) && z ~= size(matrix_tmt_backoff_3D,1))
                str_2_write = sprintf('%s%d}},',str_2_write,matrix_tmt_backoff_3D(z,i,j));
            elseif (j == size(matrix_tmt_backoff_3D,3) && i == size(matrix_tmt_backoff_3D,2) && z == size(matrix_tmt_backoff_3D,1))    
                str_2_write = sprintf('%s%d}}};',str_2_write,matrix_tmt_backoff_3D(z,i,j));
            else
                str_2_write = sprintf('%s%d,',str_2_write,matrix_tmt_backoff_3D(z,i,j));
            end
        end
    end
end


end

