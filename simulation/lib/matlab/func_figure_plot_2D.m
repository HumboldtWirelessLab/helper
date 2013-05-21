function [handler_figure] = func_figure_plot_2D(figure_number,vector_neighbours, matrix1,matrix2,text_label_y,ticks_y_step_size,text_title,legend_on,vector_legend,text_legend_title)%,vector_backoff_window_sizes_standard) 
    handler_figure = figure(figure_number);
    set(handler_figure,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm
    hold on;
    set(gcf,'PaperPositionMode','auto'); % wichtig, damit sich die Beschriftungen auf der x-Achse nicht überlappen beim Speichern
    %% Datenraten unterschiedliche Farben und MSDU-Größen unterschiedliche Symbole
    ColorSet = [[1 0 1];[0 1 1];[0 1 0];[0 0 1];[0 0 0]];
    LineStyle_marker = {'o','x','square','diamond','^','v','>','<','pentagram','hexagram','.','*','+'} ;
    LineStyle_lines = {'-','--',':','-.'};
    hcolor_counter = 1;
    %linestyle_counter = 1;
    %vector_result = zeros(1,size(matrix_tmt_backoff_3D,3));
    vector_hlegend_style_marker = zeros(1,2);%size(vector_legend,2));
    vector_hlegend_style_color = zeros(1,size(vector_legend,2));
    % for i = 1:1:size(matrix1,1)
    %hplots = zeros(1,size(matrix1,2));
    for j = 1:1:size(matrix1,2)
        pos1 = find(matrix1(:,j) == 0,1);
        pos2 = find(matrix2(:,j) == 0,1);
        if (isempty(pos1))
             pos1 = find(matrix1(:,j) == -1,1);
             if (isempty(pos1))
                pos1 = find(matrix1(:,j) == 3000,1);
                disp(pos1)
                if (isempty(pos1))
                    pos1 = size(matrix1,1);
                end
             end
        end
        if (isempty(pos2))
            
            pos2 = find(matrix2(:,j) == -1,1);
            if (isempty(pos2))
                pos2 = find(matrix2(:,j) == 3000,1);
                disp(pos2)
                if (isempty(pos2))
                    pos2 = size(matrix2,1);
                end
            end
        end
        if (j == 2)
            pos1 = pos1 - 2;
            pos2 = pos2 - 2;
        else
            pos1 = pos1 - 1;
            pos2 = pos2 - 1;
        end
        linestyle_counter = 1;   
        vector_hlegend_style_color(1,j) = plot(vector_neighbours(1,1:1:pos1),matrix1(1:1:pos1,j),LineStyle_lines{1,2},'Color',ColorSet(hcolor_counter,1:3),'LineWidth',2);
        vector_hlegend_style_marker(1,1) = plot(vector_neighbours(1,1:1:pos1),matrix1(1:1:pos1,j),LineStyle_marker{1,linestyle_counter},'LineWidth',2);
        plot(vector_neighbours(1,1:1:pos1),matrix1(1:1:pos1,j),sprintf('%s%s',LineStyle_lines{1,2},LineStyle_marker{1,linestyle_counter}),'Color',ColorSet(hcolor_counter,1:3),'LineWidth',2);
        
        linestyle_counter = 2;
        vector_hlegend_style_marker(1,2) = plot(vector_neighbours(1,1:1:pos1),matrix2(1:1:pos1,j),LineStyle_marker{1,linestyle_counter},'LineWidth',2);
        plot(vector_neighbours(1,1:1:pos2),matrix2(1:1:pos2,j),sprintf('%s%s',LineStyle_lines{1,2},LineStyle_marker{1,linestyle_counter}),'Color',ColorSet(hcolor_counter,1:3),'LineWidth',2);
        %if (linestyle_counter > size(LineStyle_marker,2))
        %        linestyle_counter = 1;
        %    else
        %        linestyle_counter = linestyle_counter + 1;
            %end
        %end
       % linestyle_counter = 1;
        if (hcolor_counter > size(ColorSet,1))
            hcolor_counter = 1;
        else
            hcolor_counter = hcolor_counter + 1;
        end
    end
    grid on
    xlabel('\bf{Anzahl von 802.11-Nachbarstationen}');
    ylabel(text_label_y);
    %value_max_x_result = max(vector_neighbours);
    %value_min_x_result = min(vector_neighbours);
    %value_max_y_result = max(max(matrix1)) + 0.01;
    %value_min_y_result = min(min(matrix1));
   
    title(text_title)
    %axis([max(value_min_x_result) max(value_max_x_result)  max(value_min_y_result) max(value_max_y_result)]);
    if (ticks_y_step_size > 0)
        Ticks_y = 0:ticks_y_step_size:max(max(matrix1)) + 1;%number_of_stations_max;
        set(gca, 'YTickMode', 'manual', 'YTick', Ticks_y, 'ylim', [0,max(max(matrix1))+ 1 + 0.5]); 
    end
    Ticks_x = 0:2:max(vector_neighbours) + 1;
    set(gca, 'XTickMode', 'manual', 'XTick', Ticks_x, 'xlim', [0,max(vector_neighbours)+ 3]); 
    if (legend_on == 1)
        legend_txt  = cell(1,size(vector_legend,2));
        for step=1:1:size(vector_legend,2)
            string = num2str(vector_legend(1,step));
            legend_txt(1,step) = {string};
        end
        %handler_legend = legend(hplots,legend_txt,'Location','BestOutside');
        
        %set(get(handler_legend,'title'),'String',text_legend_title)
        
        %legend_txt  = cell(1,2);% Unterscheidung der Verfahren
        %legend_txt(1,1) = {'an'};
        %legend_txt(1,2) = {'aus'};
        %for step=1:1:2
        %    string = num2str(vector_legend1(1,step));
        %    legend_txt(1,step) = {string};
        %end
            %hplots(1,:) = matrix_handler_legend_styles(:,1);
        handler_legend = legend(vector_hlegend_style_color,legend_txt,'Location','SouthEastOutside');
        set(get(handler_legend,'title'),'String',text_legend_title)
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
    legend_txt2  = cell(1,2);% Unterscheidung der Verfahren
        legend_txt2(1,1) = {'aus'};
        legend_txt2(1,2) = {'an'};
        text_legend_title2 = 'RTS/CTS';
    %legend_txt2  = cell(1,size(vector_legend2,2));% data_rates
    %for step=1:1:size(vector_legend2,2)
    %    string = num2str(vector_legend2(1,step));
    %    legend_txt2(1,step) = {string};
    %end
    handler_legend2 = legend(vector_hlegend_style_marker,legend_txt2,'Location','NorthEastOutside');
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
