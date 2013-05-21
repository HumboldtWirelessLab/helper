function [ handler_figure ] = func_figure_backoff_window_sizes_neighbours_different_losses(figure_number,w_approximate,vector_packet_loss,vector_neighbours,vector_of_successful_conditions,vector_backoff_window_sizes_standard,vector_legend_pos)
    handler_figure = figure(figure_number);
    set(handler_figure,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm
    ax1 = axes('Parent',handler_figure);
    hold all
        hplots = zeros(size(vector_of_successful_conditions,1),1);
        for t = 1:1:size(vector_of_successful_conditions,1)
            %no_neighbours = 1:1:vector_of_successful_conditions(t,1);
            vector_no_neighbours = vector_neighbours(1,1:1:vector_of_successful_conditions(t,1));
            vector = w_approximate(t,:);
            [ vector_shorten] = func_test_vector_shorten_2(vector, vector_of_successful_conditions(t,1));
            hplots(t,1) = plot(vector_no_neighbours,vector_shorten,'-x');
            set(hplots(t,1),'LineWidth',2);
        end
        ylabel('\bfBackoff-Fenstergröße [Slots]');
        xlabel('\bfAnzahl von 802.11-Nachbarstationen');
        h_xlabel = get(gca,'XLabel');
        set(h_xlabel,'FontSize',16); 
        h_ylabel = get(gca,'YLabel');
        set(h_ylabel,'FontSize',16); 
        set(gca,'FontSize',10,'fontweight','bold')
        grid on
        neighbours_max_2 = max(vector_of_successful_conditions) + 10;
        if (neighbours_max_2 > 100)
            neighbours_max_2 = max(vector_of_successful_conditions) + 15;
        end
        Ticks_x = 0:5:neighbours_max_2;
        set(gca, 'XTickMode', 'manual', 'XTick', Ticks_x, 'xlim', [0;neighbours_max_2]); 
        max_value = max(max(w_approximate)) + 100;
        Ticks_y = 0:250:max_value;
        set(gca, 'YTick',Ticks_y)
        set(gca, 'YTickMode', 'manual', 'YTick', Ticks_y, 'ylim', [0,max_value+ 1 + 0.5]); 
        legend_txt  = cell(1,size(vector_packet_loss,2));
        for i=1:1:size(vector_packet_loss,2)
            string = sprintf('%s', num2str(vector_packet_loss(1,i) * 100));
            legend_txt(1,i) = {string};
        end
        if (vector_legend_pos(1,1) == 'n')
            handler_legend = legend(hplots,legend_txt,'Location','NorthEastOutside');
        elseif (vector_legend_pos(1,1) == 'e')
            handler_legend = legend(hplots,legend_txt,'Location','EastOutside');
        elseif (vector_legend_pos(1,1) == 'w')
            handler_legend = legend(hplots,legend_txt,'Location','NorthWestOutside');
        elseif (vector_legend_pos(1,1) == 'm')
            handler_legend = legend(hplots,legend_txt,'Location','NorthOutside');
        end
        set(get(handler_legend,'title'),'String',{'\bfPaketverlust [%]'}) 
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
        set(gca,'FontSize',10,'fontweight','bold')
        set(gcf,'PaperPositionMode','auto'); % wichtig, damit sich die Beschriftungen auf der x-Achse nicht überlappen beim Speichern
        hold(ax2, 'on');
        set(hplots,'Parent',ax2);
        set(hleg_copy,'Parent',hf2);
        %------------- Generate Legend Standard--------------------------------
        max_y = max(vector_of_successful_conditions);
        x=zeros(1,max_y);
        initial_attempt=zeros(1,max_y);
        retransmission_first=zeros(1,max_y);
        retransmission_second=zeros(1,max_y);
        retransmission_third=zeros(1,max_y);
        retransmission_fourth=zeros(1,max_y);
        retransmission_fifth=zeros(1,max_y);
        retransmission_sixth=zeros(1,max_y);
        for k=0:1:max_y
            x(1,k+1) = k;
            initial_attempt(1,k+1)= vector_backoff_window_sizes_standard(1,1);%initial attempt
            retransmission_first(1,k+1)= vector_backoff_window_sizes_standard(1,2);%first retransmission
            retransmission_second(1,k+1)=vector_backoff_window_sizes_standard(1,3);%second retransmission
            retransmission_third(1,k+1)=vector_backoff_window_sizes_standard(1,4);%third retransmission
            retransmission_fourth(1,k+1)=vector_backoff_window_sizes_standard(1,5);%fourth retransmission
            retransmission_fifth(1,k+1)=vector_backoff_window_sizes_standard(1,6);%fith retransmission 
            retransmission_sixth(1,k+1)=vector_backoff_window_sizes_standard(1,7);%sixth retransmission 
            % retransmission_fith is max value
        end
        hplots_standard(1,1) = plot(x,initial_attempt,'blue');
        set(hplots_standard(1,1),'LineWidth',2);
        hplots_standard(2,1) = plot(x,retransmission_first,'magenta');
        set(hplots_standard(2,1),'LineWidth',2)
        hplots_standard(3,1) = plot(x,retransmission_second,'cyan');
        set(hplots_standard(3,1),'LineWidth',2)
        hplots_standard(4,1) = plot(x,retransmission_third,'red');
        set(hplots_standard(4,1),'LineWidth',2)
        hplots_standard(5,1) = plot(x,retransmission_fourth,'green');
        set(hplots_standard(5,1),'LineWidth',2)
        hplots_standard(6,1) = plot(x,retransmission_fifth,'black');
        set(hplots_standard(6,1),'LineWidth',2)
        hplots_standard(7,1) = plot(x,retransmission_sixth,'black');
        set(hplots_standard(7,1),'LineWidth',2)

        try_init = sprintf('initialer Versuch (%d)',vector_backoff_window_sizes_standard(1,1));
        try_first = sprintf('1. Wiederholung (%d)',vector_backoff_window_sizes_standard(1,2));
        try_second = sprintf('2. Wiederholung (%d)',vector_backoff_window_sizes_standard(1,3));
        try_third = sprintf('3. Wiederholung (%d)',vector_backoff_window_sizes_standard(1,4));
        try_fourth = sprintf('4. Wiederholung (%d)',vector_backoff_window_sizes_standard(1,5));
        try_fifth = sprintf('5. Wiederholung (%d)',vector_backoff_window_sizes_standard(1,6));
        try_sixth = sprintf('6. Wiederholung (%d)',vector_backoff_window_sizes_standard(1,7));
        legend_standard_txt = {try_init try_first try_second try_third try_fourth try_fifth try_sixth};
        if (vector_legend_pos(1,2) == 'e')
            hleg2 = legend(hplots_standard,legend_standard_txt,'Location','EastOutside');
        elseif (vector_legend_pos(1,2) == 'n')
            hleg2 = legend(hplots_standard,legend_standard_txt,'Location','NorthEastOutside');
        elseif (vector_legend_pos(1,2) == 'w')
            hleg2 = legend(hplots_standard,legend_standard_txt,'Location','NorthWestOutside');
        elseif (vector_legend_pos(1,2) == 'm')
            hleg2 = legend(hplots_standard,legend_standard_txt,'Location','NorthOutside');
        end
        set(get(hleg2,'title'),'String',{'\bfStandard-Backoff-Fenstergrößen [Slots]'})
        set(hleg2,'FontSize',12)
        set(get(hleg2,'title'),'FontSize',13);
        % Create a copy of the second legend and delete the original
        % This forces similar appearance and behavior for the two legends.
        hleg_copy2 = copyobj(hleg2,handler_figure);
        delete(hleg2);

        % The following two lines remove the references to properties that
        % original legend object referred to. This prevents potential errors from
        % methods like ButtonDownFcn and others that are specific to legend
        % objects.

        set(hleg_copy,'Tag','', 'ButtonDownFcn','', 'UserData', []);
        set(hleg_copy2,'Tag','', 'ButtonDownFcn','', 'UserData', []);

        % Now move the first set of plots and corresponding legend back to our
        % figure. Must also move the second set of plots to the first figure.
        set(hplots,'Parent',ax1);
        set(hplots_standard, 'Parent', ax1);
        set(hleg_copy,'Parent',handler_figure);
        xlabel('X-Data');
        close(hf2);
    hold off   
end



