function [ handler_figure ] = func_figure_simulation_neighbours_backoff_window_size_collision(figure_number,matrix)
handler_figure = figure(figure_number);
%plot(matrix_birthday_problem_collision_likelihood_packet_loss*100,matrix_collision_percent*100,'x')
set(handler_figure,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm

%ColorSet = [[1 0 1];[0 1 1];[0 1 0];[0 0 1];[0 0 0]];
%hcolor_counter = 5;
hplot = plot(matrix,'-x');
grid on

set(hplot,'LineWidth',2)

xlabel('\bf Anzahl von 802.11-Nachbarstationen');

ylabel('\bf Backoff-Fenstergröße [Slots]');
h_xlabel = get(gca,'XLabel');
set(h_xlabel,'FontSize',16); 

h_ylabel = get(gca,'YLabel');
set(h_ylabel,'FontSize',16); 

end

