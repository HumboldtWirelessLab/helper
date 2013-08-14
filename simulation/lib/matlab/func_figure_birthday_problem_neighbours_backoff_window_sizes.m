function [handler_figure] = func_figure_birthday_problem_neighbours_backoff_window_sizes(figure_number,vector_neighbours, vector_backoff_window_sizes_per_neighbour,text_label_y,ticks_y_step_size,text_title,legend_on,vector_legend,text_legend_title)%,vector_backoff_window_sizes_standard) 
    handler_figure = figure(figure_number);
    set(handler_figure,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm
    %&ax1 = axes('Parent',handler_figure);
    hold on;
    set(gcf,'PaperPositionMode','auto'); % wichtig, damit sich die Beschriftungen auf der x-Achse nicht überlappen beim Speichern
    figure(figure_number);
    hplots = plot(vector_neighbours,vector_backoff_window_sizes_per_neighbour,'LineWidth',2);
    grid on
    xlabel('\bf{Anzahl von 802.11-Nachbarstationen}');
    ylabel(text_label_y);
    value_max_x_result = max(vector_neighbours);
    value_min_x_result = min(vector_neighbours);
    value_max_y_result = max(vector_backoff_window_sizes_per_neighbour) + 0.01;
    value_min_y_result = min(vector_backoff_window_sizes_per_neighbour);
    %hplots = plot(vector_neighbours, vector_backoff_window_sizes_per_neighbour,'-x');
    %grid on
    
    title(text_title)
    axis([max(value_min_x_result) max(value_max_x_result)  max(value_min_y_result) max(value_max_y_result)]);
    if (ticks_y_step_size > 0)
        Ticks_y = 0:ticks_y_step_size:max(max(vector_backoff_window_sizes_per_neighbour)) + 1;%number_of_stations_max;
        set(gca, 'YTickMode', 'manual', 'YTick', Ticks_y, 'ylim', [0,max(max(vector_backoff_window_sizes_per_neighbour))+ 1 + 0.5]); 
    end
    Ticks_x = 0:2:max(vector_neighbours) + 1;%number_of_stations_max;
    set(gca, 'XTickMode', 'manual', 'XTick', Ticks_x, 'xlim', [0,max(vector_neighbours)+ 1]); 
    if (legend_on == 1)
        legend_txt  = cell(1,size(vector_legend,2));
        for step=1:1:size(vector_legend,2)
            string = num2str(vector_legend(1,step));
            legend_txt(1,step) = {string};
        end
        handler_legend = legend(hplots,legend_txt,'Location','BestOutside');
        set(get(handler_legend,'title'),'String',text_legend_title)
    end
    %xlabel('Anzahl von Nachbarn');
    %ylabel('Backoff-Fenstergröße');
    %xlabel('Backoff-Fenster-Größe');
    %ylabel('Kollisionswahrscheinlichkeit');
    %str = sprintf('Kollision und Backoff-Fenster-Größe für verschiedene Stationsanzahlen');
    %str = sprintf('Geburtstagsparadoxon');
    %title(str);
    %legend_txt  = cell(1,1); %size(vector_backoff_window_sizes_standard,2) + 1);
    %legend_txt(1,1) = {'Beste Kurve'};
    %legend_txt  = cell(1,size(vector_backoff_window_sizes_standard,2) + 1);
    %for step=1:1:size(vector_backoff_window_sizes_standard,2)
    %    string = num2str(vector_backoff_window_sizes_standard(1,step));
    %    legend_txt(1,step+1) = {string};
    %end
    %handler_legend = legend(hplots,legend_txt,'Location','BestOutside');
    %handler_legend = legend(hplots,legend_txt,'Location','SouthEastOutside');
   % handler_legend = legend(hplots,legend_txt,'Location','NorthEastOutside');
   % set(get(handler_legend,'title'),'String','#Nachbarn')
   % hleg_copy = copyobj(handler_legend,handler_figure);
   % delete(handler_legend);
    % Now move the first set of plots and legend to a second figure
    % Note that the LEGEND function creates references for all the plots in a
    % figure
    
    % Moving allows us to create second set of plots and legend easily without
    % having to locate and delete legend objects corresponding to the first set
    % of plots
   % hf2 = figure('visible', 'on');
   % ax2 = axes('Parent',hf2,'visible','on');
   % set(hf2,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm
   % hold(ax2, 'on');
   % set(hplots,'Parent',ax2);
   % set(hleg_copy,'Parent',hf2);
    
    %hold on
    % Für vertikale linien start
    %scale = 1;
    %y = scale*ones(1,size(vector_backoff_window_sizes_standard,2));
    %x = max(value_min_x_result):1:max(value_max_x_result);
    %stem(x,vector_backoff_window_sizes_standard,'--','marker','none');
     % Für vertikale linien ende
     %vector_line_x_min = zeros(1,size(vector_backoff_window_sizes_standard,2));
     %vector_line_x_max = zeros(1,size(vector_backoff_window_sizes_standard,2));
     %vector_line_y = zeros(1,size(vector_backoff_window_sizes_standard,2));
     
    %for i = 1:1:size(vector_backoff_window_sizes_standard,2)
    %    vector_line_x_min(1,i) = max(value_min_x_result);
    %    vector_line_x_max(1,i) = max(value_max_x_result);
    %    vector_line_y(1,i) = vector_backoff_window_sizes_standard(1,i);
    %end
  % max_y = max(vector_neighbours)+1;
%x=zeros(1,max_y);
%initial_attempt=zeros(1,max_y);
%retransmission_first=zeros(1,max_y);
%retransmission_second=zeros(1,max_y);
%retransmission_third=zeros(1,max_y);
%retransmission_fourth=zeros(1,max_y);
%retransmission_fifth=zeros(1,max_y);

%for k=0:1:max_y
%     x(1,k+1) = k;
%    initial_attempt(1,k+1)=31;%initial attempt
%    retransmission_first(1,k+1)=63;%first retransmission
%    retransmission_second(1,k+1)=127;%second retransmission
%    retransmission_third(1,k+1)=255;%third retransmission
%    retransmission_fourth(1,k+1)=511;%fourth retransmission
%    retransmission_fifth(1,k+1)=1023;%fith retransmission 
% retransmission_fith is max value
%end


   
%hia=plot(x,initial_attempt,'yellow');
%hrfirst=plot(x,retransmission_first,'magenta');
%hrsecond=plot(x,retransmission_second,'cyan');
%hrthird=plot(x,retransmission_third,'red');
%hrfourth=plot(x,retransmission_fourth,'green');
%hrfifth=plot(x,retransmission_fifth,'black');
%   hleg2 = legend([hia(1) hrfirst(1) hrsecond(1) hrthird(1) hrfourth(1) hrfifth(1)],{'initialer Versuch' '1. Wiederholung' '2.Wiederholung' '3. Wiederholung' '4. Wiederholung' '5. bis n-te Wiederholung'},'Location','SouthEastOutside');

   % Second set of plots
    %hplots2 =  line([vector_line_x_min vector_line_x_max], [vector_line_y vector_line_y],'Marker','none','LineStyle','--');
    %hleg2 = legend(hplots2,{'initialer Versuch' '1. Wiederholung' '2.Wiederholung' '3. Wiederholung' '4. Wiederholung' '5. bis n-te Wiederholung'},'Location','EastOutside');
    %hleg2 = legend(hplots2,{'initialer Versuch' '1. Wiederholung' '2.Wiederholung' '3. Wiederholung' '4. Wiederholung' '5. bis n-te Wiederholung'},'Location','NorthEast');
    % Create a copy of the second legend and delete the original
% This forces similar appearance and behavior for the two legends.
%hleg_copy2 = copyobj(hleg2,handler_figure);
%delete(hleg2);

% The following two lines remove the references to properties that
% original legend object referred to. This prevents potential errors from
% methods like ButtonDownFcn and others that are specific to legend
% objects.

%set(hleg_copy,'Tag','', 'ButtonDownFcn','', 'UserData', []);
%set(hleg_copy2,'Tag','', 'ButtonDownFcn','', 'UserData', []);


% Now move the first set of plots and corresponding legend back to our
% figure. Must also move the second set of plots to the first figure.
%set(hplots,'Parent',ax1);
%set([hia(1) hrfirst(1) hrsecond(1) hrthird(1) hrfourth(1) hrfifth(1)], 'Parent', ax1);

%set(hleg_copy,'Parent',handler_figure);
%xlabel('X-Data');

%close(hf2);
    hold off
end
