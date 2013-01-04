function [handler_figure] = func_figure_collision_sim_calc_comparison_points(figure_number,matrix_plot_1,matrix_plot_2)
%figure_number = figure_number + 1;
%matrix_plot_1 = matrix_col_occured_mean_neighbour_backoff_per_station;
%matrix_plot_2 = zeros(size(matrix_birthday_problem_collision_likelihood_packet_loss,1),size(matrix_birthday_problem_collision_likelihood_packet_loss,2));
%for i=1:1:size(matrix_birthday_problem_collision_likelihood_packet_loss,1)
%    for j=1:1:size(matrix_birthday_problem_collision_likelihood_packet_loss,2)
%        if (matrix_birthday_problem_collision_likelihood_packet_loss(i,j) > 0)
%            matrix_plot_2(i,j) = (matrix_birthday_problem_collision_likelihood_packet_loss(i,j) * packets_successful_delivered);
%        end
%    end
%end
handler_figure = figure(figure_number);
set(handler_figure,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm
hold all
    %hplots = zeros(1,size(vector_birthday_problem_neighbours,2));
    %hplots_2 = zeros(1,size(vector_birthday_problem_neighbours,2));
        for n=1:1:size(matrix_plot_1,1)
            for b=1:size(matrix_plot_1,2)
                plot(matrix_plot_2(n,b),matrix_plot_1(n,b),'x')
            %start_value_index_1 =  find(matrix_plot_1(p,:) ~=0,1);
            %x_1=start_value_index_1:5:300;
            %start_value_index_2 =  find(matrix_plot_2(p,:) ~=0,1);
            %x_2=start_value_index_2:5:300;
            %hplots(1,p) = plot(x_1,matrix_plot_1(p,start_value_index_1:5:300));
            %hplots(1,p+size(vector_birthday_problem_neighbours,2)) = plot(x_2,matrix_plot_2(p,start_value_index_2:5:300),'-x');
            end
        end
         set(gca,'FontSize',10,'fontweight','bold')
        grid on
        xlabel('Kollisionen Calc');
        ylabel('Kollisionen Sim');
        h_xlabel = get(gca,'XLabel');
        set(h_xlabel,'FontSize',16); 
        h_ylabel = get(gca,'YLabel');
        set(h_ylabel,'FontSize',16); 
        set(gcf,'PaperPositionMode','auto'); % wichtig, damit sich die Beschriftungen auf der x-Achse nicht überlappen beim Speichern

hold off


end

