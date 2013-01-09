function [handler_figure] = func_figure_backoff_collision_mean_std(figure_number,matrix,vector_neighbours_filter,vector_axes_label_x,y_label_txt)
    handler_figure = figure(figure_number);
    set(handler_figure,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm
    hold all
        hplots = zeros(1,size(vector_neighbours_filter,2));
        for p=1:1:size(vector_neighbours_filter,2)
            y=mean(matrix(:,:,p),1);% Mittelwert von jeder Spalte pro Station
            x=std(matrix(:,:,p),1,1); %Standarabweichung
            e1 = x./sqrt(size(matrix,1)); %Standardabweichung des Mittelwertes als Konsequenz des zentralen Grenzwertsatzes siehe http://www.springer.com/physics/classical+continuum+physics/book/978-3-642-13080-9: Gleichung (2.24)
            start_value_index =  find(matrix(1,:,p) ~=0,1);
            x=start_value_index:1:size(y,2);
            
            hplots(1,p) = errorbar(x,y(start_value_index:1:size(y,2)),e1(start_value_index:1:size(y,2)));
        end
        set(hplots,'LineWidth',2)
        set(gca,'FontSize',10,'fontweight','bold')
        grid on
        %YTicks = 0:2:number_of_monitoring_neighbours_max+1;
        %set(gca, 'YTick',YTicks)
        if (strcmp(y_label_txt,'Kollisionswahrscheinlichkeit [%]'))
            set(gca,'ylim', [0, 100+ 0.5]);
        end
        Ticks_x = 1:1:size(vector_axes_label_x,2);
        %x_value_max = max(Ticks_x);
        %x_value_min = max(Ticks_x);
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
        legend_txt  = cell(1,size(vector_neighbours_filter,2));
        for i=1:1:size(vector_neighbours_filter,2)
            string = num2str(vector_neighbours_filter(1,i));
            legend_txt(1,i) = {string};
        end
        handler_legend = legend(hplots,legend_txt,'Location','NorthEastOutside');
        set(get(handler_legend,'title'),'String',{'\bf{Anzahl von 802.11-Nachbarstationen}'})
        set(handler_legend,'FontSize',12)
        set(get(handler_legend,'title'),'FontSize',13);
    hold off
end

