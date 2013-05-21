function [handler_figure] = func_figure_likelihood_sim_calc_comparison(figure_number,matrix_plot_1,matrix_plot_2,vector_neighbours,vector_neighbours_filter,label_x,label_y)
handler_figure = figure(figure_number);
set(handler_figure,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm
vector_helper_x = zeros(1,size(matrix_plot_1,2));
vector_helper_y = zeros(1,size(matrix_plot_1,2));
hold all
    %hplots = zeros(1,size(matrix_plot_1,1));
    hplots = zeros(1,size(vector_neighbours_filter,2)+1);
    vector_line = 0:0.1:100; %TODO: 100 [%] durch Variable ersetzten
    counter_hplots=1;
    counter = 0;
        for n=1:1:size(vector_neighbours,2)
            if ((~isempty(find(vector_neighbours_filter == vector_neighbours(1,n), 1))))
                counter = counter + 1;
                for b=1:size(matrix_plot_1,2)
                    
                    vector_helper_x(1,b) = matrix_plot_1(counter,b);
                    vector_helper_y(1,b) = matrix_plot_2(counter,b);
                end
                
                %start_value_index =  find(vector_helper_y(1,:) ~=0,1);
                %hplots(1,counter_hplots) = plot(vector_helper_x(1,start_value_index:1:size(vector_helper_x,2)),vector_helper_y(1,start_value_index:1:size(vector_helper_y,2)),'-x');
                hplots(1,counter_hplots) = plot(vector_helper_x,vector_helper_y,'-x');
                counter_hplots = counter_hplots + 1;
            end
        end
        hplots(1,size(vector_neighbours_filter,2)+1) = plot(vector_line,vector_line);
        set(hplots,'LineWidth',2)
        set(gca,'FontSize',10,'fontweight','bold')
        grid on
        xlabel(label_x);
        ylabel(label_y);
        h_xlabel = get(gca,'XLabel');
        set(h_xlabel,'FontSize',16); 
        h_ylabel = get(gca,'YLabel');
        set(h_ylabel,'FontSize',16); 
        set(gcf,'PaperPositionMode','auto'); % wichtig, damit sich die Beschriftungen auf der x-Achse nicht überlappen beim Speichern
        set(gca, 'xlim', [0, 100 + 0.5]);
        set(gca, 'ylim', [0, 100 + 0.5]);
        legend_txt  = cell(1,size(vector_neighbours_filter,2)+1);
        
        for i=1:1:size(vector_neighbours_filter,2)
            string = num2str(vector_neighbours_filter(1,i));
            legend_txt(1,i) = {string};
        end
        string = 'ideal';
        legend_txt(1,size(vector_neighbours_filter,2)+1) = {string};
        handler_legend = legend(hplots,legend_txt,'Location','NorthEastOutside');
        set(get(handler_legend,'title'),'String',{'\bf{Nachbarstationen}'})
        set(handler_legend,'FontSize',12)
        set(get(handler_legend,'title'),'FontSize',13);
hold off


end

