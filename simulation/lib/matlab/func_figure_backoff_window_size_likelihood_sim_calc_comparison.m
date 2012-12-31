function [handler_figure] = func_figure_backoff_window_size_likelihood_sim_calc_comparison(figure_number,matrix_plot_1,matrix_plot_2,vector_birthday_problem_neighbours)
handler_figure = figure(figure_number);
set(handler_figure,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm
%hold all
%plot(matrix_plot_1(1:1:300,:),'-x')
%plot(matrix_plot_2(1:1:300,:))
hold all
    ColorSet = [[1 0 1];[0 1 1];[0 1 0];[0 0 1];[0 0 0]];
    hcolor_counter = 1;
    hplots = zeros(1,size(vector_birthday_problem_neighbours,2)*2);
    x_axis_points_value_max = 300;
    %hplots_2 = zeros(1,size(vector_birthday_problem_neighbours,2));
        for p=1:1:size(vector_birthday_problem_neighbours,2)
            %if ((~isempty(find(vector_birthday_problem_neighbours == p, 1))))
                start_value_index_1 =  find(matrix_plot_1(vector_birthday_problem_neighbours(1,p),:) ~=0,1);
                x_1=start_value_index_1:5:x_axis_points_value_max;          
                start_value_index_2 =  find(matrix_plot_2(vector_birthday_problem_neighbours(1,p),:) ~=0,1);
                x_2=start_value_index_2:5:x_axis_points_value_max;
            
                hplots(1,p) = plot(x_1,matrix_plot_1(vector_birthday_problem_neighbours(1,p),start_value_index_1:5:x_axis_points_value_max));
                hplots(1,p+size(vector_birthday_problem_neighbours,2)) = plot(x_2,matrix_plot_2(vector_birthday_problem_neighbours(1,p),start_value_index_2:5:x_axis_points_value_max),'-x');
            
                set(hplots(1,p),'Color',ColorSet(hcolor_counter,1:3),'LineWidth',2)
                set(hplots(1,p+size(vector_birthday_problem_neighbours,2)),'Color',ColorSet(hcolor_counter,1:3),'LineWidth',2)
                if (hcolor_counter >= size(ColorSet,1))
                    hcolor_counter = 1;
                else
                    hcolor_counter = hcolor_counter + 1;
                end
            %end
        end
        %set(hplots,'LineWidth',2)
        %set(hplots_2,'LineWidth',2)
        set(gca,'FontSize',10,'fontweight','bold')
        grid on
        xlabel('Backoff-Fenstergröße');
        h_xlabel = get(gca,'XLabel');
        set(h_xlabel,'FontSize',16); 
        ylabel('Kollisionswahrscheinlichkeit [%]')
        h_ylabel = get(gca,'YLabel');
        set(h_ylabel,'FontSize',16); 
                set(gcf,'PaperPositionMode','auto'); % wichtig, damit sich die Beschriftungen auf der x-Achse nicht überlappen beim Speichern
        legend_txt  = cell(1,size(vector_birthday_problem_neighbours,2)*2);
        
        for i=1:1:size(vector_birthday_problem_neighbours,2)
            string = num2str(vector_birthday_problem_neighbours(1,i));
            legend_txt(1,i) = {string};
            legend_txt(1,i+size(vector_birthday_problem_neighbours,2)) = {string};
        end
        handler_legend = legend(hplots,legend_txt,'Location','NorthEastOutside');
        set(get(handler_legend,'title'),'String',{'\bf{Nachbarstationen [Sim,Paradoxon]}'})
        set(handler_legend,'FontSize',12)
        set(get(handler_legend,'title'),'FontSize',13);
hold off


end

