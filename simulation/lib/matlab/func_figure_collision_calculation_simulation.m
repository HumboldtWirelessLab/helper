function [ handler_figure ] = func_figure_collision_calculation_simulation(figure_number,vector_neighbours,matrix1,matrix2)
handler_figure = figure(figure_number);
%plot(matrix_birthday_problem_collision_likelihood_packet_loss*100,matrix_collision_percent*100,'x')
set(handler_figure,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm
%hplot = plot(matrix1,matrix2,'-x');
hold all
hplot = zeros(1,size(vector_neighbours,2));
 for i=1:1:size(vector_neighbours,2)
    hplot(1,i) = plot(matrix1(i,:),matrix2(i,:),'-x');
 end
%hplot_1 = plot(vector_neighbours,matrix2,'-x');

% hplots(t,1) = plot(no_neighbours,vector_shorten,'-x');
%set(hplot,'Color',ColorSet(hcolor_counter,1:3),'LineWidth',2)
set(hplot,'LineWidth',2);
grid on
set(gca,'FontSize',10,'fontweight','bold')
xlabel('\bf berechnete Kollisionswahrscheinlickeit [%]');

ylabel('\bf simulierte Kollisionswahrscheinlichkeit [%]');
h_xlabel = get(gca,'XLabel');
set(h_xlabel,'FontSize',16); 

h_ylabel = get(gca,'YLabel');
set(h_ylabel,'FontSize',16); 

legend_txt  = cell(1,size(vector_neighbours,2));
 for i=1:1:size(vector_neighbours,2)
        %string = num2str(vector_packet_loss(1,i) * 100);
        string = sprintf('%s', num2str(vector_neighbours(1,i)));
        legend_txt(1,i) = {string};
 end

 
    handler_legend = legend(hplot,legend_txt,'Location','NorthEastOutside');
    set(get(handler_legend,'title'),'String',{'\bf#802.11-Nachbarstationen'}) 
    set(handler_legend,'FontSize',12)
    set(get(handler_legend,'title'),'FontSize',13);
hold off
end

