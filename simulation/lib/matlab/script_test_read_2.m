clear all; 
close all;
folder_name = 'messungen/2012-12-13';
folder_name_figure_save = 'figure_collisions';
number_of_simulation = 100;
packets_successful_delivered = 100;
vector_neighbours_filter = [2,5,10,15,20];
vector_backoff_filter = zeros(1,11);
for i=1:1:size(vector_backoff_filter,2)
    vector_backoff_filter(1,i) = 2^i;
end
figure_number = 0;
func_simulation_eval_collision(folder_name,folder_name_figure_save,number_of_simulation,packets_successful_delivered,vector_neighbours_filter,figure_number,vector_backoff_filter)
