function [handler_figure] = func_figure_plot_2D_2(figure_number,matrix1_2D,matrix2_2D,text_label_x,text_label_y,vector_legend,text_legend_title)%,ticks_y_step_size,text_title,legend_on,vector_legend,text_legend_title)%,vector_backoff_window_sizes_standard) 
    handler_figure = figure(figure_number);
    set(handler_figure,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm
    hold all;
    set(gcf,'PaperPositionMode','auto'); % wichtig, damit sich die Beschriftungen auf der x-Achse nicht überlappen beim Speichern
    %% Datenraten unterschiedliche Farben und MSDU-Größen unterschiedliche Symbole
    ColorSet = [[1 0 1];[0 1 1];[0 1 0];[0 0 1];[0 0 0]];
    LineStyle_marker = {'o','x','square','diamond','^','v','>','<','pentagram','hexagram','.','*','+'} ;
    LineStyle_lines = {'-','--',':','-.'};
    hcolor_counter = 1;
    %linestyle_counter = 1;
    %vector_result = zeros(1,size(matrix_tmt_backoff_3D,3));
    %vector_hlegend_style_marker = zeros(1,2);%size(vector_legend,2));
    %vector_hlegend_style_color = zeros(1,size(vector_legend,2));
    % for i = 1:1:size(matrix1,1)
    %hplots = zeros(1,size(matrix1,2));
    linestyle_counter = 2;
    hplots = zeros(1,size(matrix1_2D,1));
    %matrix1_new = zeros(size(matrix1_2D,1),size(vector_legend,2));
    %matrix2_new =  zeros(size(matrix1_2D,1),size(vector_legend,2));
    %for i = 1:1:size(matrix1_2D,1)
     %   for j = 1:1:size(vector_legend,2)
     %       matrix1_new(j,i) = matrix1_2D(vector_legend(1,j),i);
     %       matrix2_new(i,j) = matrix2_2D(vector_legend(1,j),i);
     %   end
    %end
    %for i = 1:1:size(matrix1_2D,1)
      for i = 1:1:size(matrix2_2D,1)
         hplots(1,i) = plot(matrix1_2D(i,:),matrix2_2D(i,:),sprintf('%s%s',LineStyle_lines{1,2},LineStyle_marker{1,linestyle_counter}),'Color',ColorSet(hcolor_counter,1:3),'LineWidth',2);
        %end
         if (hcolor_counter > size(ColorSet,1))
            hcolor_counter = 1;
        else
            hcolor_counter = hcolor_counter + 1;
        end
       end
    xlabel(text_label_x)
    ylabel(text_label_y)
    grid on
    
            legend_txt  = cell(1,size(vector_legend,2));
        for step=1:1:size(vector_legend,2)
            string = num2str(vector_legend(1,step));
            legend_txt(1,step) = {string};
        end
        handler_legend = legend(hplots,legend_txt,'Location','BestOutside');
        
        set(get(handler_legend,'title'),'String',text_legend_title)
    

    
    hold off
end
