function [handler_fig] = func_figure_birthday_problem_neighbours_collision(figure_number,matrix_neighbours, likelihood, vector_backoff_window_sizes, vector_neighbours)
   handler_fig =figure(figure_number);

    
    %--------Plot-----------------------------
     value_max_x_result = max(matrix_neighbours);
     value_min_x_result = min(matrix_neighbours);
      value_max_y_result = max(likelihood) + 0.01;
     value_min_y_result = min(likelihood);%matlab linie gestrichelt
     if (value_max_x_result == value_min_x_result);
         value_min_x_result = 0;
     end
     plot(matrix_neighbours, likelihood,'-x') 
     grid on   
    set(handler_fig,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm
legend_txt  = cell(1,length(vector_backoff_window_sizes));
 for step=1:1:length(vector_backoff_window_sizes)
        string = num2str(vector_backoff_window_sizes(1,step));
        legend_txt(1,step) = {string};
 end
  hlegh = legend(legend_txt,'Location','BestOutside');
      set(get(hlegh,'title'),'String',{sprintf('Backoff-Fenster\nGröße')})
     axis([max(value_min_x_result) max(value_max_x_result)  max(value_min_y_result) max(value_max_y_result)]);
     str = sprintf('Geburtstagsparadoxon für Backoff');
     title(str);
     Ticks_x = 0:2:max(vector_neighbours) + 1;%number_of_stations_max;
    set(gca, 'XTickMode', 'manual', 'XTick', Ticks_x, 'xlim', [0,max(vector_neighbours)+ 1 + 0.5]); 
    set(gcf,'PaperPositionMode','auto'); % wichtig, damit sich die Beschriftungen auf der x-Achse nicht überlappen beim Speichern
     xlabel('#Nachbarn');
     ylabel('Kollisionswahrscheinlichkeit [%]');

end

