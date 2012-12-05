function [ handler_figure ] = func_figure_collision_calculation_simulation(figure_number,matrix1,matrix2)
handler_figure = figure(figure_number);
%plot(matrix_birthday_problem_collision_likelihood_packet_loss*100,matrix_collision_percent*100,'x')
set(handler_figure,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm

ColorSet = [[1 0 1];[0 1 1];[0 1 0];[0 0 1];[0 0 0]];
hcolor_counter = 5;
hplot = plot(matrix1,matrix2,'x');
% hplots(t,1) = plot(no_neighbours,vector_shorten,'-x');
set(hplot,'Color',ColorSet(hcolor_counter,1:3),'LineWidth',2)
   %set(hplot,'LineWidth',2);
%end
xlabel('\bf berechnete Kollisionswahrscheinlickeit [%]');
%ylabel('\bfBackoff-Fenstergrqe');
ylabel('\bf simulierte Kollisionswahrscheinlichkeit [%]');
h_xlabel = get(gca,'XLabel');
set(h_xlabel,'FontSize',16); 

h_ylabel = get(gca,'YLabel');
set(h_ylabel,'FontSize',16); 

grid on
%plot(matrix_birthday_problem_collision_likelihood_packet_loss*100,matrix_collision_percent*100,'x')
end

