%folder_name = 'messungen/2012-12-13';
%folder_name_figure_save = 'figure_collisions';
%number_of_simulation = 100;
%no_neighbours_max = 20;
%no_backoff_window_size_max =3000;
%packets_successful_delivered = 100;
%vector_backoff = 1:1:no_backoff_window_size_max;
%vector_neighbours_filter = [2,5,10,15,20];
%    vector_backoff_filter = zeros(1,11);
%    for i=1:1:size(vector_backoff_filter,2)
%        vector_backoff_filter(1,i) = 2^i;
%    end

function func_simulation_eval_collision(folder_name,folder_name_figure_save,number_of_simulation,packets_successful_delivered,vector_neighbours_filter,figure_number,vector_backoff_filter)

    %---------------------------------Filenames--------------------------------
    %filename_1 = 'sim_matrix_results_collision_simulation_neighbour_backoff_global';
    filename_2 = 'sim_matrix_counter_collision_sim_neighbour_backoff_global';
    %filename_3 = 'sim_matrix_collision_sim_neighbour_backoff_global_per_station';
    filename_4 = 'sim_matrix_col_occured_sim_neighbour_backoff_global_per_station';
    %filename_5 = 'sim_matrix_results_collision_avg_per_station';
    %--------- Variante  -----------------------------------------------------
    %filename_csv_1 = sprintf('%s/%s',folder_name_2,filename_1);
    filename_csv_2 = sprintf('%s/%s',folder_name,filename_2);
    %filename_csv_3 = sprintf('%s/%s',folder_name_2,filename_3);
    filename_csv_4 = sprintf('%s/%s',folder_name,filename_4);
    %filename_csv_5 = sprintf('%s/%s',folder_name_2,filename_5);
    % ------------ Save Figure ------------------------------------------------
    filename_boxplot ='figure_boxplot';
    filename_errorbar = 'figure_errorbar_backoff_collision';
    filename_boxplot_likelihood = 'figure_boxplot_likelihood';
    filename_errorbar_likelihood = 'figure_errorbar_likelihood';
    collision_global = 'global';
    collision_per_station = 'per_station';
    %------------------ Read results of the simulation ------------------------
    [matrix_counter_collision_sim_neighbour_backoff_global] = func_matrix_3D_csvread(filename_csv_2,number_of_simulation);
    %[matrix_collision_sim_neighbour_backoff_global_per_station] = func_matrix_3D_csvread(filename_csv_3,number_of_simulation);
    [matrix_col_occured_sim_neighbour_backoff_global_per_station] = func_matrix_3D_csvread(filename_csv_4,number_of_simulation);
    matrix_station = zeros(number_of_simulation,size(vector_neighbours_filter,2));
    matrix_station_2 = zeros(number_of_simulation,size(vector_neighbours_filter,2));
    for i=1:1:size(vector_neighbours_filter,2)
        for j=1:1:number_of_simulation
            matrix_station(j,i) = mean(matrix_counter_collision_sim_neighbour_backoff_global(j,vector_neighbours_filter(1,i),:));
            matrix_station_2(j,i) = mean(matrix_col_occured_sim_neighbour_backoff_global_per_station(j,vector_neighbours_filter(1,i),:));
        end
    end

    %figure_number = 1;
    %handler_fig_10 = func_figure_boxplot(figure_number,matrix_station,vector_neighbours_filter);

    %figure_number = 2;
    %handler_fig_11 = func_figure_boxplot(figure_number,matrix_station_2,vector_neighbours_filter);


    matrix_1 = zeros(number_of_simulation,size(vector_backoff_filter,2),size(vector_neighbours_filter,2));
    matrix_2 = zeros(number_of_simulation,size(vector_backoff_filter,2),size(vector_neighbours_filter,2));
    for i=1:1:size(vector_backoff_filter,2)
        for p=1:1:size(vector_neighbours_filter,2)
            for j=1:1:number_of_simulation
                matrix_1(j,i,p) = matrix_counter_collision_sim_neighbour_backoff_global(j,vector_neighbours_filter(1,p),vector_backoff_filter(1,i));
                matrix_2(j,i,p) = matrix_col_occured_sim_neighbour_backoff_global_per_station(j,vector_neighbours_filter(1,p),vector_backoff_filter(1,i));
            end
        end
    end

    handler_figure_12  = zeros(2,size(vector_neighbours_filter,2));
    for i=1:1:2
        for p=1:1:size(vector_neighbours_filter,2)
            figure_number = figure_number + 1;
            if ( i== 1)
                handler_figure_12(i,p) = func_figure_boxplot(figure_number,matrix_1(:,:,p),vector_backoff_filter,'Anzahl von Kollisionen');
                filename = sprintf('%s/%s_%s_%d.eps',folder_name_figure_save,filename_boxplot,collision_global,vector_neighbours_filter(1,p));
                saveas(handler_figure_12(i,p),filename,'eps2c');
            else
                handler_figure_12(i,p) = func_figure_boxplot(figure_number,matrix_2(:,:,p),vector_backoff_filter,'Anzahl von Kollisionen');
                filename = sprintf('%s/%s_%s_%d.eps',folder_name_figure_save,filename_boxplot,collision_per_station,vector_neighbours_filter(1,p));
                saveas(handler_figure_12(i,p),filename,'eps2c');
            end
        end
    end

    figure_number = figure_number + 1;
    [handler_figure_1] = func_figure_backoff_collision_mean_std(figure_number,matrix_1,vector_neighbours_filter,vector_backoff_filter,'Anzahl von Kollisionen');
    filename_new_1 = sprintf('%s/%s_%s.eps',folder_name_figure_save,filename_errorbar,collision_global);
    saveas(handler_figure_1,filename_new_1,'eps2c');
    figure_number = figure_number + 1;
    [handler_figure] = func_figure_backoff_collision_mean_std(figure_number,matrix_2,vector_neighbours_filter,vector_backoff_filter,'Anzahl von Kollisionen');
    filename_new_2 = sprintf('%s/%s_%s.eps',folder_name_figure_save,filename_errorbar,collision_per_station);
    saveas(handler_figure,filename_new_2,'eps2c');

    [matrix_likelihood_collisions_1] = func_sim_mean_per_station_calculation(matrix_1,packets_successful_delivered);
    [matrix_likelihood_collisions_2] = func_sim_mean_per_station_calculation(matrix_2,packets_successful_delivered);
    [matrix_likelihood_collisions_percent_1] = func_matrix_3D_convert_2_percent(matrix_likelihood_collisions_1);
    [matrix_likelihood_collisions_percent_2] = func_matrix_3D_convert_2_percent(matrix_likelihood_collisions_2);
    handler_figure_11  = zeros(2,size(vector_neighbours_filter,2));
    for i=1:1:2
        for p=1:1:size(vector_neighbours_filter,2)
            figure_number = figure_number + 1;
            if ( i== 1)
                handler_figure_11(i,p) = func_figure_boxplot(figure_number,matrix_likelihood_collisions_percent_1(:,:,p),vector_backoff_filter,'Kollisionswahrscheinlichkeit [%]');
                filename = sprintf('%s/%s_%s_%d.eps',folder_name_figure_save,filename_boxplot_likelihood,collision_global,vector_neighbours_filter(1,p));
                saveas(handler_figure_11(i,p),filename,'eps2c');
            else
                handler_figure_11(i,p) = func_figure_boxplot(figure_number,matrix_likelihood_collisions_percent_2(:,:,p),vector_backoff_filter,'Kollisionswahrscheinlichkeit [%]');
                filename = sprintf('%s/%s_%s_%d.eps',folder_name_figure_save,filename_boxplot_likelihood,collision_per_station,vector_neighbours_filter(1,p));
                saveas(handler_figure_11(i,p),filename,'eps2c');
            end
        end
    end
    figure_number = figure_number + 1;
    handler_figure_2 = func_figure_backoff_collision_mean_std(figure_number,matrix_likelihood_collisions_percent_1,vector_neighbours_filter,vector_backoff_filter,'Kollisionswahrscheinlichkeit [%]');
    filename_new_3 = sprintf('%s/%s_%s.eps',folder_name_figure_save,filename_errorbar_likelihood,collision_global);
    saveas(handler_figure_2,filename_new_3,'eps2c');
    figure_number = figure_number + 1;
    handler_figure_3 = func_figure_backoff_collision_mean_std(figure_number,matrix_likelihood_collisions_percent_2,vector_neighbours_filter,vector_backoff_filter,'Kollisionswahrscheinlichkeit [%]');
    filename_new_4 = sprintf('%s/%s_%s.eps',folder_name_figure_save,filename_errorbar_likelihood,collision_per_station);
    saveas(handler_figure_3,filename_new_4,'eps2c');
end

