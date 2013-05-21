function [ str_2_write ] = func_matrix_4D_2_c_plusplus(name, matrix_results_collisions_air_capacity_4D )
str_2_write = sprintf('static const uint32_t _backoff_matrix_tmt_%s_4D[%d][%d][%d][%d]={',name,size(matrix_results_collisions_air_capacity_4D,1),size(matrix_results_collisions_air_capacity_4D,2),size(matrix_results_collisions_air_capacity_4D,3),size(matrix_results_collisions_air_capacity_4D,4));
for t = 1:1:size(matrix_results_collisions_air_capacity_4D,1)
        str_2_write = sprintf('%s{',str_2_write);
for z = 1:1:size(matrix_results_collisions_air_capacity_4D,2)
    str_2_write = sprintf('%s{',str_2_write);
    for i = 1:1:size(matrix_results_collisions_air_capacity_4D,3)
        str_2_write = sprintf('%s{',str_2_write);
        for j = 1:1:size(matrix_results_collisions_air_capacity_4D,4)
            if (j == 1)
                str_2_write = sprintf('%s%d,',str_2_write,matrix_results_collisions_air_capacity_4D(t,z,i,j));
            elseif (j == size(matrix_results_collisions_air_capacity_4D,4) && i ~= size(matrix_results_collisions_air_capacity_4D,3))
                str_2_write = sprintf('%s%d},',str_2_write,matrix_results_collisions_air_capacity_4D(t,z,i,j));
            elseif (j == size(matrix_results_collisions_air_capacity_4D,4) && i == size(matrix_results_collisions_air_capacity_4D,3) && z ~= size(matrix_results_collisions_air_capacity_4D,2))
                str_2_write = sprintf('%s%d}},',str_2_write,matrix_results_collisions_air_capacity_4D(t,z,i,j));
            elseif (j == size(matrix_results_collisions_air_capacity_4D,4) && i == size(matrix_results_collisions_air_capacity_4D,3) && z == size(matrix_results_collisions_air_capacity_4D,2) && t ~= size(matrix_results_collisions_air_capacity_4D,1))    
                str_2_write = sprintf('%s%d}}},',str_2_write,matrix_results_collisions_air_capacity_4D(t,z,i,j));
            elseif (j == size(matrix_results_collisions_air_capacity_4D,4) && i == size(matrix_results_collisions_air_capacity_4D,3) && z == size(matrix_results_collisions_air_capacity_4D,2) && t == size(matrix_results_collisions_air_capacity_4D,1))    
                str_2_write = sprintf('%s%d}}}};',str_2_write,matrix_results_collisions_air_capacity_4D(t,z,i,j));
            else
                str_2_write = sprintf('%s%d,',str_2_write,matrix_results_collisions_air_capacity_4D(t,z,i,j));
            end
        end
    end
end
end


end

