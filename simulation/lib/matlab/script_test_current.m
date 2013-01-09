close all;
clear all; 
folder_name_1 = 'messungen/v1';
folder_name_2 = 'messungen/v2';
folder_name_3 = 'messungen/v3';
folder_name_4 = 'messungen/v4';
folder_name_5 = 'messungen/v7';
folder_name_6 = 'messungen/v8';
folder_name =folder_name_1;
number_of_simulation = 100;
simulation_packets_successful_delivered = 100;
evaluation_packets_successful_delivered_read_3D_on = 1; % 0:= 0ff; 1:= On
figure_comparison_points_on = 0; %0:= Off; 1:= On
debug = 1;
%[matrix_likelihood_collisions_percent_global,matrix_likelihood_collisions_percent_per_station,matrix_collision_occured_neighbour_backoff_global,matrix_col_occured_neighbour_backoff_global_per_station] = func_sim_collision_get(number_of_simulation,packets_successful_delivered);
%[matrix_likelihood_collisions_percent_global,matrix_collision_occured_neighbour_backoff_global] = func_sim_collision_global_get(folder_name,number_of_simulation,packets_successful_delivered);
%[matrix_likelihood_collisions_percent_per_station,matrix_col_occured_neighbour_backoff_per_station] = func_sim_collision_per_station_get(folder_name,number_of_simulation,packets_successful_delivered);

if (debug == 1)
    [matrix_packets_delivered] = func_sim_packets_delivered_global_get(folder_name,number_of_simulation,evaluation_packets_successful_delivered_read_3D_on);
    [matrix_col_occured_mean_neighbour_backoff_per_station,matrix_likelihood_collisions_percent_per_station,matrix_col_occured_simulation_all_neighbour_backoff_per_station,matrix_likelihood_simulation_all_collisions_percent_per_station] = func_sim_collision_per_station_get(folder_name,number_of_simulation,matrix_packets_delivered,evaluation_packets_successful_delivered_read_3D_on);
    %------------------- Backoff with birthday problem   -------------------------------------
    no_backoff_window_size_max = size(matrix_col_occured_mean_neighbour_backoff_per_station,2);
    no_neighbours_max =  size(matrix_col_occured_mean_neighbour_backoff_per_station,1);
    %----------- Birthday Problem Configuration  -------------------------
    vector_packet_loss_upper_limit = [0.1, 0.2, 0.3, 0.4, 0.5];
    %---------------- Birthday-Problem configuration ------------------------
    vector_birthday_problem_cw_sizes = 1:1:no_backoff_window_size_max; % Vector for different contention window sizes
    vector_birthday_problem_neighbours = 1:1:no_neighbours_max; %vector for different neighbours
    [matrix_packet_loss_neighbours_backoff_windows_birthday_problem,matrix_packet_loss_neighbours_backoff_windows_approximation, matrix_birthday_problem_collision_likelihood_packet_loss,vector_of_successful_conditions] = func_birthday_problem_calc(vector_birthday_problem_neighbours,vector_birthday_problem_cw_sizes,vector_packet_loss_upper_limit);    
    matrix_plot_1 = matrix_likelihood_collisions_percent_per_station * 100;
    matrix_plot_2 = matrix_birthday_problem_collision_likelihood_packet_loss * 100;
    figure_number = 1;
    %vector_neighbours_filter=1:5:size(vector_birthday_problem_neighbours,2);
    vector_neighbours_filter=[1,5,9,15,20,25];
    [handler_figure_01] = func_figure_backoff_window_size_likelihood_sim_calc_comparison(figure_number,matrix_plot_1,matrix_plot_2,vector_neighbours_filter);
    figure_number = figure_number + 1;
    [handler_figure] = func_figure_likelihood_sim_calc_comparison(figure_number,matrix_plot_1,matrix_plot_2,vector_neighbours_filter);
    if (figure_comparison_points_on)
        figure_number = figure_number + 1;
        [handler_figure_10] = func_figure_likelihood_sim_calc_comparison_points(figure_number,matrix_plot_1,matrix_plot_2);
    end
elseif (debug==0)
    vector_backoff = 1:1:3000;
    simulation_of_collision = 2; %new simulation
    no_neighbours_max = 25;
    write_on = 0;
    func_simulation(simulation_of_collision,vector_backoff,no_neighbours_max,simulation_packets_successful_delivered,number_of_simulation,folder_name,write_on);  
end
