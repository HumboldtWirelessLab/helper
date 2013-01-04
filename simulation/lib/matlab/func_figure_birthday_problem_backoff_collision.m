function [hfig_1] = func_figure_birthday_problem_backoff_collision(figure_number,matrix_backoff_windows, likelihood, vector_neighbours, vector_backoff_window_sizes_standard) 
    hfig_1 = figure(figure_number);
    hold all
    set(gcf,'PaperPositionMode','auto'); % wichtig, damit sich die Beschriftungen auf der x-Achse nicht überlappen beim Speichern
    value_max_x_result = max(matrix_backoff_windows);
    value_min_x_result = min(matrix_backoff_windows);
    value_max_y_result = max(likelihood) + 0.01;
    value_min_y_result = min(likelihood);
    plot(matrix_backoff_windows, likelihood,'-x')
    grid on
    set(hfig_1 ,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm
   
    axis([max(value_min_x_result) max(value_max_x_result)  max(value_min_y_result) max(value_max_y_result)]);
    
    %Ticks_y = 0:50:max(vector_backoff_window_sizes_per_neighbour) + 1;%number_of_stations_max;
    %set(gca, 'YTickMode', 'manual', 'YTick', Ticks_y, 'ylim', [0,max(vector_backoff_window_sizes_per_neighbour)+ 1 + 0.5]); 
    %Ticks_x = 0:2:max(vector_neighbours) + 1;%number_of_stations_max;
    %set(gca, 'XTickMode', 'manual', 'XTick', Ticks_x, 'xlim', [0,max(vector_neighbours)+ 0.5]); 
    
    %xlabel('Anzahl Nachbarn');
    %ylabel('Backoff-Fenster-Größe');
    xlabel('Backoff-Fenstergröße [Slots]');
    ylabel('Kollisionswahrscheinlichkeit [%]');
    str = sprintf('Kollision und Backoff-Fenster-Größe für verschiedene Stationsanzahlen');
    %str = sprintf('Geburtstagsparadoxon');
    title(str);
    %hold on
    % Für vertikale linien start
    scale = 1;
    y = scale*ones(1,size(vector_backoff_window_sizes_standard,2));
    %x = max(value_min_x_result):1:max(value_max_x_result);
    stem(vector_backoff_window_sizes_standard,y,'--','marker','none');
     % Für vertikale linien ende
    %for i = 1:1:size(vector_backoff_window_sizes_standard,2)
    %    y = vector_backoff_window_sizes_standard(1,i);
    %    line([max(value_min_x_result) max(value_max_x_result)], [y y],'Marker','none','LineStyle','--')
    %end
    %legend_txt  = cell(1,size(vector_backoff_window_sizes_standard,2) + 1);
    %legend_txt(1,1) = {'Beste Kurve'};
    legend_txt  = cell(1,size(vector_neighbours,2));
    for step=1:1:size(vector_neighbours,2)
        string = num2str(vector_neighbours(1,step));
        %legend_txt(1,step+1) = {string};
        legend_txt(1,step) = {string};
    end
    legh = legend(legend_txt,'Location','BestOutside');
    set(get(legh,'title'),'String','#Nachbarn')
    hold off
end









%Ticks_x = 0:50:max(v_backoff) + 1;%number_of_stations_max;
%set(gca, 'XTickMode', 'manual', 'XTick', Ticks_x, 'xlim', [0,max(v_backoff)+ 1 + 0.5]); 

