function [handler_figure] = func_figure_likelihood_sim_calc_comparison_points(figure_number,matrix_plot_1,matrix_plot_2)
%figure_number = figure_number + 1;
handler_figure = figure(figure_number);
set(handler_figure,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm
%vector_helper_x = zeros(1,size(matrix_plot_1,2));
%vector_helper_y = zeros(1,size(matrix_plot_1,2));
hold all
    %hplots = zeros(1,size(vector_birthday_problem_neighbours,2));
    %hplots_2 = zeros(1,size(vector_birthday_problem_neighbours,2));
    ColorSet = [[1 0 1];[0 1 1];[0 1 0];[0 0 1];[0 0 0]];
    hcolor_counter = 1;
        for n=1:1:size(matrix_plot_1,1)
            for b=1:size(matrix_plot_1,2)
                %vector_helper_x(1,b) = matrix_plot_2(n,b);
                %vector_helper_y(1,b) = matrix_plot_1(n,b);
                plot(matrix_plot_2(n,b),matrix_plot_1(n,b),'x','Color',ColorSet(hcolor_counter,1:3))
                %set(hplots(1,p),'Color',ColorSet(hcolor_counter,1:3),'LineWidth',2)
            %set(hplots(1,p+size(vector_birthday_problem_neighbours,2)),'Color',ColorSet(hcolor_counter,1:3),'LineWidth',2)
            
            %start_value_index_1 =  find(matrix_plot_1(p,:) ~=0,1);
            %x_1=start_value_index_1:5:300;
            %start_value_index_2 =  find(matrix_plot_2(p,:) ~=0,1);
            %x_2=start_value_index_2:5:300;
            %hplots(1,p) = plot(x_1,matrix_plot_1(p,start_value_index_1:5:300));
            %hplots(1,p+size(vector_birthday_problem_neighbours,2)) = plot(x_2,matrix_plot_2(p,start_value_index_2:5:300),'-x');
            end
            if (hcolor_counter > size(ColorSet,1))
                hcolor_counter = 1;
            else
                hcolor_counter = hcolor_counter + 1;
            end
            %plot(vector_helper_x,vector_helper_y,'-x')
        end
         set(gca,'FontSize',10,'fontweight','bold')
        grid on
        xlabel('Kollisionswkt. Calc [%]');
        ylabel('Kollisionswkt. Sim [%]');
        h_xlabel = get(gca,'XLabel');
        set(h_xlabel,'FontSize',16); 
        h_ylabel = get(gca,'YLabel');
        set(h_ylabel,'FontSize',16); 
        set(gcf,'PaperPositionMode','auto'); % wichtig, damit sich die Beschriftungen auf der x-Achse nicht überlappen beim Speichern
         set(gca, 'xlim', [0, 100 + 0.5]);
         set(gca, 'ylim', [0, 100 + 0.5]);
hold off


end

