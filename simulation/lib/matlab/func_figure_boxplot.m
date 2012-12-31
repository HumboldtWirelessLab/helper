function handler_fig_10 = func_figure_boxplot(figure_number,matrix_station,vector_axes_label_x,y_label_txt)%,number_of_monitoring_neighbours_max,number_of_stations_max)
    handler_fig_10 = figure(figure_number);
    set(handler_fig_10,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm
    hplots = boxplot(matrix_station);
    set(hplots,'LineWidth',2);
    set(gca,'FontSize',10)
    set(gca,'FontSize',10,'fontweight','bold')
    grid on
    %YTicks = 0:2:number_of_monitoring_neighbours_max+1;
    %set(gca, 'YTick',YTicks)
    Ticks_x = 1:1:size(vector_axes_label_x,2);
    %x_value_max = max(Ticks_x);
    %x_value_min = max(Ticks_x);
    if (strcmp(y_label_txt,'Kollisionswahrscheinlichkeit [%]'))
        set(gca,'ylim', [0, 100+ 0.5]);
    end
    set(gca, 'XTickMode', 'manual', 'XTick', Ticks_x); %, 'xlim', [x_value_min, x_value_max + 0.5]);
    set(gca,'XTickLabel',vector_axes_label_x);
    ylabel(y_label_txt);
    %ylabel('Anzahl von Kollisionen');
    xlabel('Backoff-Fenstergröße');
    h_xlabel = get(gca,'XLabel');
    set(h_xlabel,'FontSize',16); 
    h_ylabel = get(gca,'YLabel');
    set(h_ylabel,'FontSize',16); 
    set(gcf,'PaperPositionMode','auto'); % wichtig, damit sich die Beschriftungen auf der x-Achse nicht überlappen beim Speichern
end

