close all;
clear all;
debug = 0;
if (debug == 1)
[matrix_result,vector_rates_data,vector_msdu_sizes] = func_msdu_rts_cts_on();

string_x = '';
for i = 1:1:size(vector_rates_data,2)
    if (strcmp(string_x, ''))
        string_x = sprintf(' & %d',vector_rates_data(1,i));
    else
        string_x = sprintf('%s & %d',string_x,vector_rates_data(1,i));
    end
end
string_x = sprintf('%s \\ \n',string_x);
for j = 1:1:size(vector_msdu_sizes,2)
    string_x = sprintf('%s %d &',string_x,vector_msdu_sizes(1,j));
    for i = 1:1:size(vector_rates_data,2)
        if (strcmp(string_x, ''))
            string_x = sprintf('%d &',matrix_result(i,j));
        else
            string_x = sprintf('%s %d &',string_x,matrix_result(i,j));
        end
    end
    string_x = sprintf('%s \\ \n', string_x);
end

%string_x
end
vector_packet_loss_upper_limit = [0.1, 0.2, 0.3, 0.4, 0.5];
vector_rates_data = [1,6,24,54];
vector_msdu_sizes = [500, 1500, 3000, 8000];
vector_no_neighbours = 1:1:25;
folder_name_2 = 'messungen/v2';
folder_name =folder_name_2;
file_directory_collision_air_capacity = sprintf('%s/%s/%s',folder_name,'collision','air_capacity');
file_directory_collision_efficiency = sprintf('%s/%s/%s',folder_name,'collision','efficiency');
file_directory_collision_backoff = sprintf('%s/%s/%s',folder_name,'collision','backoff');

fileanme_collision_air_capacity = 'collison_air_capacity';
fileanme_collision_air_capacity_rts = 'rts_collison_air_capacity';

fileanme_collision_efficiency = 'collison_efficiency';
fileanme_collision_efficiency_rts = 'rts_collison_efficiency';

fileanme_collision_backoff = 'collision_backoff';
fileanme_collision_backoff_rts = 'rts_collision_backoff';


[matrix_4D_air_capacity] = func_csvread_matrix_4D(file_directory_collision_air_capacity,fileanme_collision_air_capacity,size(vector_rates_data,2),size(vector_msdu_sizes,2),size(vector_no_neighbours,2),size(vector_packet_loss_upper_limit,2));
[matrix_4D_air_capacity_rts] = func_csvread_matrix_4D(file_directory_collision_air_capacity,fileanme_collision_air_capacity_rts,size(vector_rates_data,2),size(vector_msdu_sizes,2),size(vector_no_neighbours,2),size(vector_packet_loss_upper_limit,2));

[matrix_4D_efficiency] = func_csvread_matrix_4D(file_directory_collision_efficiency,fileanme_collision_efficiency,size(vector_rates_data,2),size(vector_msdu_sizes,2),size(vector_no_neighbours,2),size(vector_packet_loss_upper_limit,2));
[matrix_4D_efficiency_rts] = func_csvread_matrix_4D(file_directory_collision_efficiency,fileanme_collision_efficiency_rts,size(vector_rates_data,2),size(vector_msdu_sizes,2),size(vector_no_neighbours,2),size(vector_packet_loss_upper_limit,2));

[matrix_4D_backoff] = func_csvread_matrix_4D(file_directory_collision_backoff,fileanme_collision_backoff,size(vector_rates_data,2),size(vector_msdu_sizes,2),size(vector_no_neighbours,2),size(vector_packet_loss_upper_limit,2));
[matrix_4D_backoff_rts] = func_csvread_matrix_4D(file_directory_collision_backoff,fileanme_collision_backoff_rts,size(vector_rates_data,2),size(vector_msdu_sizes,2),size(vector_no_neighbours,2),size(vector_packet_loss_upper_limit,2));


%matrix1 = zeros(size(vector_no_neighbours,2),size(vector_packet_loss_upper_limit,2));
figure_number = 1;
figure_save_on = 1;
file_directory_save_air_capacity = sprintf('%s/figures',file_directory_collision_air_capacity);
file_directory_save_collision_efficiency = sprintf('%s/figures',file_directory_collision_efficiency);
file_directory_save_collision_backoff = sprintf('%s/figures',file_directory_collision_backoff);

for i = 1:1:1 %size(vector_rates_data,2)
    for j = 1:1:1 %size(vector_msdu_sizes,2)
        [matrix_3d] = func_convert_matrix_4D_2_3D(matrix_4D_air_capacity,i);
        [matrix_2d_air_capacity] = func_convert_matrix_3D_2_2D(matrix_3d,j);

        [matrix_3d] = func_convert_matrix_4D_2_3D(matrix_4D_air_capacity_rts,i);
        [matrix_2d_air_capacity_rts] = func_convert_matrix_3D_2_2D(matrix_3d,j);
        
        [matrix_3d] = func_convert_matrix_4D_2_3D(matrix_4D_efficiency,i);
        [matrix_2d_efficiency] = func_convert_matrix_3D_2_2D(matrix_3d,j);
        
        [matrix_3d] = func_convert_matrix_4D_2_3D(matrix_4D_efficiency_rts,i);
        [matrix_2d_efficiency_rts] = func_convert_matrix_3D_2_2D(matrix_3d,j);
        
        [matrix_3d] = func_convert_matrix_4D_2_3D(matrix_4D_backoff,i);
        [matrix_2d_backoff] = func_convert_matrix_3D_2_2D(matrix_3d,j);
        
        [matrix_3d] = func_convert_matrix_4D_2_3D(matrix_4D_backoff_rts,i);
        [matrix_2d_backoff_rts] = func_convert_matrix_3D_2_2D(matrix_3d,j);
        
        ticks_y_step_size = -1;
        legend_on = 1;
        vector_legend = vector_packet_loss_upper_limit * 100;
        text_legend_title = 'Paketverluste [%]';
        text_label_y = '\bf{Durchsatz [Mbps]}';
        text_title = sprintf('Rate:=%d; MSDU-Größe:=%d',vector_rates_data(1,i),vector_msdu_sizes(1,j));
        [handler_figure] = func_figure_plot_2D(figure_number,vector_no_neighbours, matrix_2d_air_capacity, matrix_2d_air_capacity_rts,text_label_y,ticks_y_step_size,text_title,legend_on,vector_legend,text_legend_title);% Lookup-Table
        if (figure_save_on == 1)
            string = num2str(figure_number);
            file_na = sprintf('%s/evaluation_simulation_rts_cts_%s',file_directory_save_air_capacity,string);
            saveas(handler_figure,file_na,'epsc')
        end
        figure_number = figure_number + 1;
        
        ticks_y_step_size = -1;
        legend_on = 1;
        vector_legend = vector_packet_loss_upper_limit * 100;
        text_legend_title = 'Paketverluste [%]';
        text_label_y = '\bf{Effizienz}';
        text_title = sprintf('Rate:=%d; MSDU-Größe:=%d',vector_rates_data(1,i),vector_msdu_sizes(1,j));
        [handler_figure] = func_figure_plot_2D(figure_number,vector_no_neighbours, matrix_2d_efficiency, matrix_2d_efficiency_rts,text_label_y,ticks_y_step_size,text_title,legend_on,vector_legend,text_legend_title);% Lookup-Table
        if (figure_save_on == 1)
            string = num2str(figure_number);
            file_na = sprintf('%s/evaluation_simulation_rts_cts_%s',file_directory_save_collision_efficiency,string);
            saveas(handler_figure,file_na,'epsc')
        end
        figure_number = figure_number + 1;
        
        ticks_y_step_size = -1;
        legend_on = 1;
        vector_legend = vector_packet_loss_upper_limit * 100;
        text_legend_title = 'Paketverluste [%]';
        text_label_y = '\bf{Backoff-Fenstergrößen [Slots]}';
        text_title = sprintf('Rate:=%d; MSDU-Größe:=%d',vector_rates_data(1,i),vector_msdu_sizes(1,j));
        [handler_figure] = func_figure_plot_2D(figure_number,vector_no_neighbours, matrix_2d_backoff, matrix_2d_backoff_rts,text_label_y,ticks_y_step_size,text_title,legend_on,vector_legend,text_legend_title);% Lookup-Table
        disp(matrix_2d_backoff)
        if (figure_save_on == 1)
            string = num2str(figure_number);
            file_na = sprintf('%s/evaluation_simulation_rts_cts_%s',file_directory_save_collision_backoff,string);
            saveas(handler_figure,file_na,'epsc')
        end
        figure_number = figure_number + 1;
    end
end
%[handler_figure] = func_figure_plot_2D(figure_number,vector_no_neighbours, matrix_2d, matrix_2d_rts,text_label_y,ticks_y_step_size,text_title,legend_on,vector_legend,text_legend_title)%,vector_backoff_window_sizes_standard) 
       

