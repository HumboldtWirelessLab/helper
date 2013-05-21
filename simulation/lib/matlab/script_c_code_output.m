str_2_write = sprintf('static const uint32_t _backoff_matrix_birthday_problem_intuitv[%d][%d]={',size(matrix_packet_neighbours_backoff_birthday_problem_intuitiv,1),size(matrix_packet_neighbours_backoff_birthday_problem_intuitiv,2));
for i = 1:1:size(matrix_packet_neighbours_backoff_birthday_problem_intuitiv,1)
    str_2_write = sprintf('%s{',str_2_write);
    for j = 1:1:size(matrix_packet_neighbours_backoff_birthday_problem_intuitiv,2)
        if (j == 1)
            str_2_write = sprintf('%s%d,',str_2_write,matrix_packet_neighbours_backoff_birthday_problem_intuitiv(i,j));
        elseif (j == size(matrix_packet_neighbours_backoff_birthday_problem_intuitiv,2) && i ~= size(matrix_packet_neighbours_backoff_birthday_problem_intuitiv,1))
             str_2_write = sprintf('%s%d},',str_2_write,matrix_packet_neighbours_backoff_birthday_problem_intuitiv(i,j));
        elseif (j == size(matrix_packet_neighbours_backoff_birthday_problem_intuitiv,2) && i == size(matrix_packet_neighbours_backoff_birthday_problem_intuitiv,1))
             str_2_write = sprintf('%s%d}};',str_2_write,matrix_packet_neighbours_backoff_birthday_problem_intuitiv(i,j));

        else
             str_2_write = sprintf('%s%d,',str_2_write,matrix_packet_neighbours_backoff_birthday_problem_intuitiv(i,j));
        end
    end
end
str_2_write

str_2_write = sprintf('static const uint32_t _backoff_matrix_birthday_problem_classic[%d][%d]={',size(matrix_packet_loss_neighbours_backoff_birthday_problem_classic,1),size(matrix_packet_loss_neighbours_backoff_birthday_problem_classic,2));
for i = 1:1:size(matrix_packet_loss_neighbours_backoff_birthday_problem_classic,1)
    str_2_write = sprintf('%s{',str_2_write);
    for j = 1:1:size(matrix_packet_loss_neighbours_backoff_birthday_problem_classic,2)
        if (j == 1)
            str_2_write = sprintf('%s%d,',str_2_write,matrix_packet_loss_neighbours_backoff_birthday_problem_classic(i,j));
        elseif (j == size(matrix_packet_loss_neighbours_backoff_birthday_problem_classic,2) && i ~= size(matrix_packet_loss_neighbours_backoff_birthday_problem_classic,1))
             str_2_write = sprintf('%s%d},',str_2_write,matrix_packet_loss_neighbours_backoff_birthday_problem_classic(i,j));
        elseif (j == size(matrix_packet_loss_neighbours_backoff_birthday_problem_classic,2) && i == size(matrix_packet_loss_neighbours_backoff_birthday_problem_classic,1))
             str_2_write = sprintf('%s%d}};',str_2_write,matrix_packet_loss_neighbours_backoff_birthday_problem_classic(i,j));

        else
             str_2_write = sprintf('%s%d,',str_2_write,matrix_packet_loss_neighbours_backoff_birthday_problem_classic(i,j));
        end
    end
end

str_2_write

str_2_write = sprintf('static const uint32_t _backoff_packet_loss[%d]={',size(vector_packet_loss_upper_limit,2));
    for j = 1:1:size(vector_packet_loss_upper_limit,2)
        if (j == 1)
            str_2_write = sprintf('%s%d,',str_2_write,vector_packet_loss_upper_limit(1,j) * 100);
        elseif (j == size(vector_packet_loss_upper_limit,2))
             str_2_write = sprintf('%s%d};',str_2_write,vector_packet_loss_upper_limit(1,j)*100);
        else
             str_2_write = sprintf('%s%d,',str_2_write,vector_packet_loss_upper_limit(1,j)*100);
        end
    end

str_2_write
name = 'backoff';
[ str_2_write ] = func_matrix_3D_2_c_plusplus(name, matrix_tmt_backoff_3D );

name = 'air_capacity';
[ str_2_write ] = func_matrix_3D_2_c_plusplus(name, matrix_tmt_air_capacity_3D );

str_2_write

name = 'backoff';
[ str_2_write ] = func_matrix_4D_2_c_plusplus(name, matrix_results_collisions_backoff_4D );
str_2_write

name = 'air_capacity';
[ str_2_write ] = func_matrix_4D_2_c_plusplus(name, matrix_results_collisions_air_capacity_4D );
str_2_write
