function [handler_figure] = func_figure_evaluation_tmt_efficiency_msdu_sizes(figure_number,vector_msdu_sizes, matrix_tmt_backoff_3D,text_label_x,text_label_y,ticks_y_step_size,ticks_y_max,text_title,legend_on,vector_legend1,text_legend_title1,vector_legend2,text_legend_title2)%,vector_backoff_window_sizes_standard) 
    handler_figure = figure(figure_number);
    set(handler_figure,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm
    %&ax1 = axes('Parent',handler_figure);
    hold on;
    set(gcf,'PaperPositionMode','auto'); % wichtig, damit sich die Beschriftungen auf der x-Achse nicht überlappen beim Speichern
    %figure(figure_number);
    %% TODO Datenraten unterschiedliche Farben und MSDU-Größen unterschiedliche Symbole
    ColorSet = [[1 0 1];[0 1 1];[0 1 0];[0 0 1];[0 0 0]];
    LineStyle_marker = {'o','x','square','diamond','^','v','>','<','pentagram','hexagram','.','*','+'} ;
    LineStyle_lines = {'-','--',':','-.'};
    hcolor_counter = 1;
    linestyle_counter = 1;
    vector_result = zeros(1,size(matrix_tmt_backoff_3D,2));
    vector_hlegend_style_marker = zeros(1,size(vector_legend2,2));
    vector_hlegend_style_color = zeros(1,size(vector_legend1,2));
    for i = 1:1:size(vector_legend1,2) %data_rates 
        for j = 1:1:size(vector_legend2,2) %no_neighbours         
            vector_result(1,:) = matrix_tmt_backoff_3D(i,:,j);
            vector_hlegend_style_color(1,i) = plot(vector_msdu_sizes,vector_result,LineStyle_lines{1,2},'Color',ColorSet(hcolor_counter,1:3),'LineWidth',2);
            vector_hlegend_style_marker(1,j) = plot(vector_msdu_sizes,vector_result,LineStyle_marker{1,linestyle_counter},'LineWidth',2);
            plot(vector_msdu_sizes,vector_result,sprintf('%s%s',LineStyle_lines{1,2},LineStyle_marker{1,linestyle_counter}),'Color',ColorSet(hcolor_counter,1:3),'LineWidth',2);
            %plot(vector_neighbours,vector_result,LineStyle{1,linestyle_counter},'Color',ColorSet(hcolor_counter,1:3),'LineWidth',2);
            if (linestyle_counter == size(LineStyle_marker,2))
                linestyle_counter = 1;
            else
                linestyle_counter = linestyle_counter + 1;
            end
        end
        linestyle_counter = 1;
        if (hcolor_counter == size(ColorSet,1))
            hcolor_counter = 1;
        else
            hcolor_counter = hcolor_counter + 1;
        end
    end
    grid on
    xlabel(text_label_x,'FontSize',16);
    ylabel(text_label_y,'FontSize',16);
    
    title(text_title)


    if (ticks_y_step_size > 0)
        Ticks_y = 0:ticks_y_step_size:100 + 1;%number_of_stations_max;
        set(gca, 'YTickMode', 'manual', 'YTick', Ticks_y, 'ylim', [0,ticks_y_max+ 1 + 0.5]); 
    end
    %value_max_y_result = max(vector_backoff_window_sizes_per_neighbour) + 0.01;
    %value_min_y_result = min(vector_backoff_window_sizes_per_neighbour);
    %value_max_x_result = max(vector_neighbours);
    %value_min_x_result = min(vector_neighbours);
    %axis([max(value_min_x_result) max(value_max_x_result)  max(value_min_y_result) max(value_max_y_result)]);
    %Ticks_x = 0:2:max(vector_neighbours) + 1;%number_of_stations_max;
    %set(gca, 'XTickMode', 'manual', 'XTick', Ticks_x, 'xlim', [0,max(vector_neighbours)+ 1]); 
    if (legend_on == 1)
        legend_txt  = cell(1,size(vector_legend1,2));% data_rates
        for step=1:1:size(vector_legend1,2)
            string = num2str(vector_legend1(1,step));
            legend_txt(1,step) = {string};
        end
            %hplots(1,:) = matrix_handler_legend_styles(:,1);
        handler_legend = legend(vector_hlegend_style_color,legend_txt,'Location','NorthWest');
        set(get(handler_legend,'title'),'String',text_legend_title1)
        set(handler_legend,'FontSize',12)
        set(get(handler_legend,'title'),'FontSize',13);
        
        
        
    
    
    hleg_copy = copyobj(handler_legend,handler_figure);
    delete(handler_legend);
    % Now move the first set of plots and legend to a second figure
    % Note that the LEGEND function creates references for all the plots in a
    % figure
    
    % Moving allows us to create second set of plots and legend easily without
    % having to locate and delete legend objects corresponding to the first set
    % of plots
    hf2 = figure('visible', 'on');
    ax2 = axes('Parent',hf2,'visible','on');
    set(hf2,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm
    hold(ax2, 'on');
    
    set(vector_hlegend_style_marker,'Parent',ax2);
    set(hleg_copy,'Parent',hf2);
    % Second set of plots
    legend_txt2  = cell(1,size(vector_legend2,2));% data_rates
    for step=1:1:size(vector_legend2,2)
        string = num2str(vector_legend2(1,step));
        legend_txt2(1,step) = {string};
    end
    handler_legend2 = legend(vector_hlegend_style_marker,legend_txt2,'Location','SouthEastOutside');
    set(get(handler_legend2,'title'),'String',text_legend_title2)
    set(handler_legend2,'FontSize',12)
     set(get(handler_legend2,'title'),'FontSize',13);
        
    % Create a copy of the second legend and delete the original
    % This forces similar appearance and behavior for the two legends.
    hleg_copy2 = copyobj(handler_legend2,handler_figure);
    delete(handler_legend2);

    % The following two lines remove the references to properties that
    % original legend object referred to. This prevents potential errors from
    % methods like ButtonDownFcn and others that are specific to legend
    % objects.

    set(hleg_copy,'Tag','', 'ButtonDownFcn','', 'UserData', []);
    set(hleg_copy2,'Tag','', 'ButtonDownFcn','', 'UserData', []);


    % Now move the first set of plots and corresponding legend back to our
    % figure. Must also move the second set of plots to the first figure.
    set(vector_hlegend_style_color,'Parent',ax2);
    set(vector_hlegend_style_marker, 'Parent', ax2);
    set(hleg_copy,'Parent',handler_figure);
    xlabel('X-Data');
    close(hf2);
    end
    hold off
end


