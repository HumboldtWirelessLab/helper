function [handler_figure] = func_figure_birthday_problem_simulation_comparison(figure_number,vector_birthday_problem_neighbours,matrix_packetloss_neighbours_2_backoff_window_sizes_sim,matrix_packetloss_neighbours_2_backoff_window_sizes_calc)
handler_figure = figure(figure_number);
set(handler_figure,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm
%ax1 = axes('Parent',handler_figure);
hold all
%hplots = zeros(size(vector_birthday_problem_neighbours,1),1);
%for t = 1:1:size(vector_birthday_problem_neighbours,1)
%    no_neighbours = 1:1:vector_birthday_problem_neighbours(t,1);
%    vector = w_approximate(t,:);
%    [ vector_shorten] = func_test_vector_shorten_2(vector, vector_of_successful_conditions(t,1));
%plot(v_neighbours,w_approximate,'-x')
%   hplots(t,1) = plot(no_neighbours,vector_shorten,'-x');
%   set(hplots(t,1),'LineWidth',2);
%end
plot(vector_birthday_problem_neighbours,matrix_packetloss_neighbours_2_backoff_window_sizes_sim,'-x')
plot(vector_birthday_problem_neighbours,matrix_packetloss_neighbours_2_backoff_window_sizes_calc,'-.')

ylabel('\bfBackoff-Fenstergröße [Slots]');
%ylabel('\bfBackoff-Fenstergrqe');
xlabel('\bfAnzahl von 802.11-Nachbarstationen');
h_xlabel = get(gca,'XLabel');
set(h_xlabel,'FontSize',16); 
set(gca,'FontSize',10,'fontweight','bold')
h_ylabel = get(gca,'YLabel');
set(h_ylabel,'FontSize',16); 

grid on
%neighbours_max_2 = max(vector_of_successful_conditions) + 10;
neighbours_max_2 = max(vector_birthday_problem_neighbours) + 10;

Ticks_x = 0:5:neighbours_max_2;%number_of_stations_max;
%neighbours_max = neighbours_max + 0.5;
set(gca, 'XTickMode', 'manual', 'XTick', Ticks_x, 'xlim', [0;neighbours_max_2]); 
max_value = 3100;%max(max(matrix_1)) + 1;
Ticks_y = 0:250:max_value;
set(gca, 'YTick',Ticks_y)
set(gca, 'YTickMode', 'manual', 'YTick', Ticks_y, 'ylim', [0,max_value+ 1 + 0.5]); 
end
