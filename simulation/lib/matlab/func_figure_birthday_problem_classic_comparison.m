function [  handler_figure ] = func_figure_birthday_problem_classic_comparison(figure_number,matrix_packet_loss_neighbours_backoff_birthday_problem_classic,matrix_packet_loss_neighbours_backoff_windows_birthday_problem,vector_of_successful_conditions_classic,vector_of_successful_conditions)
handler_figure = figure(figure_number);
set(handler_figure,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm
ax1 = axes('Parent',handler_figure);
hplots = zeros(size(vector_of_successful_conditions,1),1);
h2plots = zeros(size(vector_of_successful_conditions,1),1);
%hcolor ={'magenta','cyan','blue','black','green'};
ColorSet = [[1 0 1];[0 1 1];[0 1 0];[0 0 1];[0 0 0]];
hcolor_counter = 1;
hold all 
for t = 1:1:size(vector_of_successful_conditions,1)
    no_neighbours = 1:1:vector_of_successful_conditions(t,1);
    vector = matrix_packet_loss_neighbours_backoff_windows_birthday_problem(t,:);
    [ vector_shorten] = func_test_vector_shorten_2(vector, vector_of_successful_conditions(t,1));
%plot(v_neighbours,w_approximate,'-x')
    hplots(t,1) = plot(no_neighbours,vector_shorten,'x');
    set(hplots(t,1),'Color',ColorSet(hcolor_counter,1:3),'LineWidth',2)
    if (hcolor_counter > size(ColorSet,1))
        hcolor_counter = 1;
    else
        hcolor_counter = hcolor_counter + 1;
    end
    
end
hold off
end

