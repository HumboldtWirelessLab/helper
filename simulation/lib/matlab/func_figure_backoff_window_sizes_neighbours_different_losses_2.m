function [ handler_figure ] = func_figure_backoff_window_sizes_neighbours_different_losses_2(figure_number,matrix_1,matrix_2,vector_packet_loss,vector_of_successful_conditions,vector_backoff_window_sizes_standard)

handler_figure = figure(figure_number);
set(handler_figure,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm
ax1 = axes('Parent',handler_figure);
hplots = zeros(size(vector_of_successful_conditions,1),1);
h2plots = zeros(size(vector_of_successful_conditions,1),1);
hold all
for t = 1:1:size(vector_of_successful_conditions,1)
    no_neighbours = 1:1:vector_of_successful_conditions(t,1);
    vector = matrix_1(t,:);
    [ vector_shorten] = func_test_vector_shorten_2(vector, vector_of_successful_conditions(t,1));
%plot(v_neighbours,w_approximate,'-x')
    hplots(t,1) = plot(no_neighbours,vector_shorten,'x');
end
ylabel('Backoff-Fenstergröße');
xlabel('Anzahl von Nachbarn');
grid on
neighbours_max_2 = max(vector_of_successful_conditions) + 10;
Ticks_x = 0:5:neighbours_max_2;%number_of_stations_max;
%neighbours_max = neighbours_max + 0.5;
set(gca, 'XTickMode', 'manual', 'XTick', Ticks_x, 'xlim', [0;neighbours_max_2]); 
legend_txt  = cell(1,size(vector_packet_loss,2));
 for i=1:1:size(vector_packet_loss,2)
        string = num2str(vector_packet_loss(1,i) * 100);
        legend_txt(1,i) = {string};
 end
 %hl = legend(legend_txt,'Location','BestOutside');
 %set(get(hl,'title'),'String',{'Paketverlust [%]'})  
 handler_legend = legend(hplots,legend_txt,'Location','NorthEastOutside');
 set(get(handler_legend,'title'),'String',{'Paketverlust [%]'}) 
 hleg_copy = copyobj(handler_legend,handler_figure);
 delete(handler_legend);
 

    % Now move the first set of plots and legend to a second figure
    % Note that the LEGEND function creates references for all the plots in a
    % figure
    
    % Moving allows us to create second set of plots and legend easily without
    % having to locate and delete legend objects corresponding to the first set
    % of plots
    hf3 = figure('visible', 'on');
    ax3 = axes('Parent',hf3,'visible','on');
    set(hf3,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm
    hold(ax3, 'on');
    set(hplots,'Parent',ax3);
    set(hleg_copy,'Parent',hf3);
    
for t = 1:1:size(vector_of_successful_conditions,1)
    no_neighbours = 1:1:vector_of_successful_conditions(t,1);
    vector = matrix_2(t,:);
    [ vector_shorten_2] = func_test_vector_shorten_2(vector, vector_of_successful_conditions(t,1));
%plot(v_neighbours,w_approximate,'-x')
   h2plots(t,1) =  plot(no_neighbours,vector_shorten_2,'r-.');
end
hleg3 = legend(h2plots,legend_txt,'Location','EastOutside');
  %hleg2 = legend([hia(1) hrfirst(1) hrsecond(1) hrthird(1) hrfourth(1) hrfifth(1)],{'initialer Versuch' '1. Wiederholung' '2.Wiederholung' '3. Wiederholung' '4. Wiederholung' '5. bis n-te Wiederholung'},'Location','SouthEastOutside');
    set(get(hleg3,'title'),'String',{'Paketverlust [%]'}) 
   % Second set of plots
    %hplots2 =  line([vector_line_x_min vector_line_x_max], [vector_line_y vector_line_y],'Marker','none','LineStyle','--');
    %hleg2 = legend(hplots2,{'initialer Versuch' '1. Wiederholung' '2.Wiederholung' '3. Wiederholung' '4. Wiederholung' '5. bis n-te Wiederholung'},'Location','EastOutside');
    %hleg2 = legend(hplots2,{'initialer Versuch' '1. Wiederholung' '2.Wiederholung' '3. Wiederholung' '4. Wiederholung' '5. bis n-te Wiederholung'},'Location','NorthEast');
    % Create a copy of the second legend and delete the original
% This forces similar appearance and behavior for the two legends.
hleg_copy3 = copyobj(hleg3,handler_figure);
delete(hleg3);


 hf2 = figure('visible', 'on');
    ax2 = axes('Parent',hf2,'visible','on');
    set(hf2,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm
    hold(ax2, 'on');
    set(hplots,'Parent',ax2);
    set(hleg_copy,'Parent',hf2);
    
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
   max_y = max(vector_of_successful_conditions)+1;
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

%hplots_standard = zeros(size(vector_backoff_window_sizes_standard,2),1);   
hplots_standard(1,1) = plot(x,initial_attempt,'blue');
hplots_standard(2,1) = plot(x,retransmission_first,'magenta');
hplots_standard(3,1) = plot(x,retransmission_second,'cyan');
hplots_standard(4,1) = plot(x,retransmission_third,'red');
hplots_standard(5,1) = plot(x,retransmission_fourth,'green');
hplots_standard(6,1) = plot(x,retransmission_fifth,'black');
hplots_standard(7,1) = plot(x,retransmission_sixth,'black');

try_init = sprintf('initialer Versuch (%d)',vector_backoff_window_sizes_standard(1,1));
try_first = sprintf('1. Wiederholung (%d)',vector_backoff_window_sizes_standard(1,2));
try_second = sprintf('2.Wiederholung (%d)',vector_backoff_window_sizes_standard(1,3));
try_third = sprintf('3.Wiederholung (%d)',vector_backoff_window_sizes_standard(1,4));
try_fourth = sprintf('4.Wiederholung (%d)',vector_backoff_window_sizes_standard(1,5));
try_fifth = sprintf('5.Wiederholung (%d)',vector_backoff_window_sizes_standard(1,6));
try_sixth = sprintf('6.Wiederholung (%d)',vector_backoff_window_sizes_standard(1,7));
legend_standard_txt = {try_init try_first try_second try_third try_fourth try_fifth try_sixth};
 hleg2 = legend(hplots_standard,legend_standard_txt,'Location','SouthEastOutside');
set(get(hleg2,'title'),'String',{'Standard-Backoff-Fenstergrößen [Slots]'}) 
% This forces similar appearance and behavior for the two legends.
hleg_copy2 = copyobj(hleg2,handler_figure);
delete(hleg2);


% The following two lines remove the references to properties that
% original legend object referred to. This prevents potential errors from
% methods like ButtonDownFcn and others that are specific to legend
% objects.

set(hleg_copy,'Tag','', 'ButtonDownFcn','', 'UserData', []);
set(hleg_copy3,'Tag','', 'ButtonDownFcn','', 'UserData', []);
set(hleg_copy2,'Tag','', 'ButtonDownFcn','', 'UserData', []);

% Now move the first set of plots and corresponding legend back to our
% figure. Must also move the second set of plots to the first figure.
set(hplots,'Parent',ax1);
set(h2plots, 'Parent', ax1);
set(hplots_standard, 'Parent', ax1);

set(hleg_copy,'Parent',handler_figure);
xlabel('X-Data');

close(hf3);
close(hf2);








%neighbours_max = max(v_neighbours) + 1;
%Ticks_x = 0:2:neighbours_max;%number_of_stations_max;
%neighbours_max = neighbours_max + 0.5;
%set(gca, 'XTickMode', 'manual', 'XTick', Ticks_x, 'xlim', [0;neighbours_max]); 
%max_value = max(max(w_approximate)) + 15;
%Ticks_y = 0:50:max_value;
%set(gca, 'YTick',Ticks_y)
%set(gca, 'YTickMode', 'manual', 'YTick', Ticks_y, 'ylim', [0,max_value+ 1 + 0.5]); 



%value_max_x_result = max(v_neighbours);
%value_min_x_result = min(v_neighbours);
    
 %for i = 1:1:size(vector_backoff_window_sizes_standard,2)
 %   y = vector_backoff_window_sizes_standard(1,i);
 %   line([max(value_min_x_result) max(value_max_x_result)], [y y],'Marker','none','LineStyle','--')
 %end
 %legend_txt  = cell(1,size(vector_backoff_window_sizes_standard,2));

 %for step=1:1:size(vector_backoff_window_sizes_standard,2)
 %   string = num2str(vector_backoff_window_sizes_standard(1,step));
 %   legend_txt(1,step) = {string};
%end
 hold off   



end



