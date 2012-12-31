function [handler_figure]  = func_figure_sim_backoff_likelihood_collisions(figure_number,matrix,vector_neighbours_filter,vector_axes_label_x,number_of_simulation,packets_successful_delivered)
    handler_figure = figure(figure_number);
    set(handler_figure,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm
    hold all
        hplots = zeros(1,size(vector_neighbours_filter,2));
        for p=1:1:size(vector_neighbours_filter,2)
            hplots(1,p) = plot(matrix(:,:,p),matrix(:,:,p));
        end
        set(hplots,'LineWidth',2)
        grid on
        %YTicks = 0:2:number_of_monitoring_neighbours_max+1;
        %set(gca, 'YTick',YTicks)
  
        Ticks_x = 1:1:size(vector_axes_label_x,2);
        %x_value_max = max(Ticks_x);
        %x_value_min = max(Ticks_x);
        set(gca, 'XTickMode', 'manual', 'XTick', Ticks_x); %, 'xlim', [x_value_min, x_value_max + 0.5]);
        set(gca,'XTickLabel',vector_axes_label_x);
        ylabel('Anzahl von Kollisionen');
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
        set(get(handler_legend,'title'),'String',{'\bf{Anzahl von Stationen}'})
        set(handler_legend,'FontSize',12)
        set(get(handler_legend,'title'),'FontSize',13);
    hold off
end

