function [handler_figure] = func_figure_likelihood_sim_calc_comparison(figure_number,matrix_plot_1,matrix_plot_2,vector_birthday_problem_neighbours)
handler_figure = figure(figure_number);
set(handler_figure,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm
vector_helper_x = zeros(1,size(matrix_plot_1,2));
vector_helper_y = zeros(1,size(matrix_plot_1,2));
hold all
    %hplots = zeros(1,size(matrix_plot_1,1));
    hplots = zeros(1,size(vector_birthday_problem_neighbours,2));
    counter_hplots=1;
        for n=1:1:size(matrix_plot_1,1)
            if ((~isempty(find(vector_birthday_problem_neighbours == n, 1))))
                for b=1:size(matrix_plot_1,2)
                    vector_helper_x(1,b) = matrix_plot_2(n,b);
                    vector_helper_y(1,b) = matrix_plot_1(n,b);
                end
                start_value_index =  find(vector_helper_y(1,:) ~=0,1);
                hplots(1,counter_hplots) = plot(vector_helper_x(1,start_value_index:1:size(vector_helper_x,2)),vector_helper_y(1,start_value_index:1:size(vector_helper_y,2)),'-x');
                counter_hplots = counter_hplots + 1;
            end
        end
        set(hplots,'LineWidth',2)
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
        legend_txt  = cell(1,size(vector_birthday_problem_neighbours,2));
        
        for i=1:1:size(vector_birthday_problem_neighbours,2)
            string = num2str(vector_birthday_problem_neighbours(1,i));
            legend_txt(1,i) = {string};
        end
        handler_legend = legend(hplots,legend_txt,'Location','NorthEastOutside');
        set(get(handler_legend,'title'),'String',{'\bf{Nachbarstationen}'})
        set(handler_legend,'FontSize',12)
        set(get(handler_legend,'title'),'FontSize',13);
hold off


end

