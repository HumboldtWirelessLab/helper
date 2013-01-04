function [ handler_figure ] = func_figure_simulation_neighbours_backoff_window_size(figure_number,vector_neighbours,matrix,vector_packet_loss)
handler_figure = figure(figure_number);
%plot(matrix_birthday_problem_collision_likelihood_packet_loss*100,matrix_collision_percent*100,'x')
set(handler_figure,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm

%ColorSet = [[1 0 1];[0 1 1];[0 1 0];[0 0 1];[0 0 0]];
%hcolor_counter = 5;
hplot = plot(vector_neighbours,matrix,'-x');
grid on
% hplots(t,1) = plot(no_neighbours,vector_shorten,'-x');
set(hplot,'LineWidth',2)
   %set(hplot,'LineWidth',2);
%end
xlabel('\bf Anzahl von 802.11-Nachbarstationen');
%ylabel('\bfBackoff-Fenstergrqe');
ylabel('\bf Backoff-Fenstergröße [Slots]');
h_xlabel = get(gca,'XLabel');
set(h_xlabel,'FontSize',16); 
set(gca,'FontSize',10,'fontweight','bold')
h_ylabel = get(gca,'YLabel');
set(h_ylabel,'FontSize',16); 
legend_txt  = cell(1,size(vector_packet_loss,2));
 for i=1:1:size(vector_packet_loss,2)
        %string = num2str(vector_packet_loss(1,i) * 100);
        string = sprintf('%s', num2str(vector_packet_loss(1,i) * 100));
        legend_txt(1,i) = {string};
 end
    handler_legend = legend(hplot,legend_txt,'Location','NorthEastOutside');
    set(get(handler_legend,'title'),'String',{'\bfPaketverlust [%]'}) 
    set(handler_legend,'FontSize',12)
    set(get(handler_legend,'title'),'FontSize',13);

%plot(matrix_birthday_problem_collision_likelihood_packet_loss*100,matrix_collision_percent*100,'x')
end

