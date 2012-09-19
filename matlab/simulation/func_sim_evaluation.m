function [ output_args ] = func_sim_evaluation(vector_rates,vector_msdu,matrix_tmt_neighbours,matrix_tmt_backoff,matrix_tmt_collisions,matrix_tmt_collisions_percent,matrix_results_bandwidth_efficiency,matrix_tmt_backoff_birthday_problem,matrix_collision,matrix_birthday_problem_collision_likelihood_packet_loss,matrix_tmt_backoff_birthday_problem_approximation)

if (max(max(matrix_tmt_collisions)) == 0) %case: collision free
    
    [number_of_rates,number_of_msdus] =size(matrix_tmt_neighbours);
    matrix_tmt_msdu = zeros(number_of_rates,number_of_msdus);
    for n=1:1:number_of_rates
        for t=1:1:number_of_msdus
            matrix_tmt_msdu(n,t) = matrix_tmt_neighbours(n,t,1);
        end
    end
    figure(1)
    grid on
    hold all
        plot(vector_msdu,matrix_tmt_msdu)
        xlabel('MSDU-Größe [Bytes]');
    ylabel('Durchsatz[Mb/s]');
    number = size(vector_rates,2);
    legend_txt  =cell(1,number);
    for i = 1:1:number
        string = num2str(vector_rates(1,i));
        legend_txt(1,i) = {string};
    end
    hl_2= legend(legend_txt,'Location','EastOutside');
    set(get(hl_2,'title'),'String',{sprintf('Datenraten [Mb/s]')})
    hold off
    
    
    [number_of_rates_max,number_of_msdus_max] =size(matrix_results_bandwidth_efficiency);
    matrix_bandwidth_efficiency_msdu = zeros(number_of_rates_max,number_of_msdus_max);
    for n=1:1:number_of_rates_max
        for t=1:1:number_of_msdus_max
            matrix_bandwidth_efficiency_msdu(n,t) = matrix_results_bandwidth_efficiency(n,t,1);
        end
    end
    
    figure(2)
    grid on
    hold all
        plot(vector_msdu,matrix_bandwidth_efficiency_msdu)
        xlabel('MSDU-Größe [Bytes]');
    ylabel('Efficiency[percent]');
    number = size(vector_rates,2);
    legend_txt  =cell(1,number);
    for i = 1:1:number
        string = num2str(vector_rates(1,i));
        legend_txt(1,i) = {string};
    end
    hl_2= legend(legend_txt,'Location','EastOutside');
    set(get(hl_2,'title'),'String',{sprintf('Datenraten [Mb/s]')})
    hold off
else %case: collisions occured
    debug = 0;
if(debug == 1)
    %hold all
    [number_of_rates,number_of_msdus,number_of_neighbours] =size(matrix_tmt_neighbours);
    matrix_tmt_msdu = zeros(number_of_neighbours,number_of_msdus-1);
    for n=1:1:number_of_rates
        for t=2:1:number_of_msdus
            for z=1:1:number_of_neighbours
                matrix_tmt_msdu(z,t-1) = matrix_tmt_neighbours(n,t,z);
            end
        end
        figure(n)
        
        vector_number_of_neighbours = 1:1:number_of_neighbours;
        plot(vector_number_of_neighbours,matrix_tmt_msdu)
        grid on
        %xlabel('MSDU-Größe [Bytes]');
        xlabel('Anzahl von Nachbarn');
        ylabel('Durchsatz[Mb/s]');
        title_string = sprintf('Datenrate = %f Mbps',vector_rates(1,n));
        title(title_string)
        %vector_number_of_neighbours = 1:1:number_of_neighbours;
        legend_txt  =cell(1,number_of_msdus-1);
        for i = 2:1:number_of_msdus
            string = num2str(vector_msdu(1,i));
            legend_txt(1,i-1) = {string};
        end
        hl_2= legend(legend_txt,'Location','EastOutside');
        %set(get(hl_2,'title'),'String',{sprintf('Anzahl von Nachbarn')})
        set(get(hl_2,'title'),'String',{sprintf('MSDU-Größe [Bytes]')})
    end
    
    
    next_figure_number = number_of_rates + 1;
        [number_of_rates,number_of_msdus,number_of_neighbours] =size(matrix_tmt_collisions);
    matrix_number_of_collisions = zeros(number_of_neighbours,number_of_msdus-1);
    for n=1:1:number_of_rates
        for t=2:1:number_of_msdus
            for z=1:1:number_of_neighbours
                matrix_number_of_collisions(z,t-1) = matrix_tmt_collisions(n,t,z);
            end
        end
        figure(next_figure_number)
        vector_number_of_neighbours = 1:1:number_of_neighbours;
        plot(vector_number_of_neighbours,matrix_number_of_collisions)
        grid on
        %xlabel('MSDU-Größe [Bytes]');
        xlabel('Anzahl von Nachbarn');
        ylabel('Anzahl Kollisionen');
         title_string = sprintf('Datenrate = %f Mbps',vector_rates(1,n));
        title(title_string)
        %vector_number_of_neighbours = 1:1:number_of_neighbours;
        legend_txt  =cell(1,number_of_msdus-1);
        for i = 2:1:number_of_msdus
            string = num2str(vector_msdu(1,i));
            legend_txt(1,i-1) = {string};
        end
        hl_2= legend(legend_txt,'Location','EastOutside');
        %set(get(hl_2,'title'),'String',{sprintf('Anzahl von Nachbarn')})
        set(get(hl_2,'title'),'String',{sprintf('MSDU-Größe [Bytes]')})
        next_figure_number = next_figure_number + 1;
    end

        next_figure_number = next_figure_number+ 1;
        [number_of_rates,number_of_msdus,number_of_neighbours] =size(matrix_tmt_backoff);
    matrix_number_of_backoff_sizes = zeros(number_of_neighbours,number_of_msdus-1);
    for n=1:1:number_of_rates
        for t=2:1:number_of_msdus
            for z=1:1:number_of_neighbours
                matrix_number_of_backoff_sizes(z,t-1) = matrix_tmt_backoff(n,t,z);
            end
        end
        figure(next_figure_number)
        vector_number_of_neighbours = 1:1:number_of_neighbours;
        plot(vector_number_of_neighbours,matrix_number_of_backoff_sizes)
        grid on
        %xlabel('MSDU-Größe [Bytes]');
        xlabel('Anzahl von Nachbarn');
        ylabel('Backoff-Fenstergröße');
        title_string = sprintf('Datenrate = %f Mbps',vector_rates(1,n));
        title(title_string)
        %vector_number_of_neighbours = 1:1:number_of_neighbours;
        legend_txt  =cell(1,number_of_msdus-1);
        for i = 2:1:number_of_msdus
            string = num2str(vector_msdu(1,i));
            legend_txt(1,i-1) = {string};
        end
        hl_2= legend(legend_txt,'Location','EastOutside');
        %set(get(hl_2,'title'),'String',{sprintf('Anzahl von Nachbarn')})
        set(get(hl_2,'title'),'String',{sprintf('MSDU-Größe [Bytes]')})
        next_figure_number = next_figure_number + 1;
    end
    next_figure_number = next_figure_number+ 1;
    [number_of_rates,number_of_msdus,number_of_neighbours] =size(matrix_results_bandwidth_efficiency);
    matrix_bandwidth_efficiency_plot = zeros(number_of_neighbours,number_of_msdus-1);
    for n=1:1:number_of_rates
        for t=2:1:number_of_msdus
            for z=1:1:number_of_neighbours
                matrix_bandwidth_efficiency_plot(z,t-1) = matrix_results_bandwidth_efficiency(n,t,z);
            end
        end
        figure(next_figure_number)
        vector_number_of_neighbours = 1:1:number_of_neighbours;
        plot(vector_number_of_neighbours,matrix_bandwidth_efficiency_plot)
        grid on
        xlabel('Anzahl Nachbarn');
        ylabel('Efficiency[percent]');
        title_string = sprintf('Datenrate = %f Mbps',vector_rates(1,n));
        title(title_string)
        legend_txt  =cell(1,number_of_msdus-1);
        for i = 2:1:number_of_msdus
            string = num2str(vector_msdu(1,i));
            legend_txt(1,i-1) = {string};
        end
        hl_2= legend(legend_txt,'Location','EastOutside');
        %set(get(hl_2,'title'),'String',{sprintf('Anzahl von Nachbarn')})
        set(get(hl_2,'title'),'String',{sprintf('MSDU-Größe [Bytes]')})
        next_figure_number = next_figure_number + 1;
    end


    next_figure_number = next_figure_number+ 1;
    [number_of_rates,number_of_msdus,number_of_neighbours] =size(matrix_tmt_collisions_percent);
    %matrix_tmt_collisions_percent_plot = zeros(number_of_neighbours,number_of_msdus-1);
    matrix_tmt_backoff_birthday_problem_plot = zeros(number_of_neighbours,number_of_msdus-1);
    for n=1:1:number_of_rates
        for t=2:1:number_of_msdus
            for z=1:1:number_of_neighbours
                %matrix_tmt_collisions_percent_plot(z,t-1) = matrix_tmt_collisions_percent(n,t,z);
                matrix_tmt_backoff_birthday_problem_plot(z,t-1)= matrix_tmt_backoff_birthday_problem(n,t,z);  
            end
        end
        figure(next_figure_number)
        hold all
        vector_number_of_neighbours = 1:1:number_of_neighbours;
        %plot(vector_number_of_neighbours,matrix_tmt_collisions_percent_plot)
        plot(vector_number_of_neighbours,matrix_tmt_backoff_birthday_problem_plot,'-x')  
        grid on
        xlabel('Anzahl Nachbarn');
        ylabel('Kollisionen[percent]');
        title_string = sprintf('Datenrate = %f Mbps',vector_rates(1,n));
        title(title_string)
        legend_txt  =cell(1,number_of_msdus-1);
        for i = 2:1:number_of_msdus
            string = num2str(vector_msdu(1,i));
            legend_txt(1,i-1) = {string};
        end
        hl_2= legend(legend_txt,'Location','EastOutside');
        set(get(hl_2,'title'),'String',{sprintf('MSDU-Größe [Bytes]')})
        hold off
        next_figure_number = next_figure_number + 1;
    end
    
    

    next_figure_number = next_figure_number+ 1;
    [number_of_rates,number_of_msdus,number_of_neighbours] =size(matrix_tmt_collisions_percent);
    matrix_tmt_collisions_percent_plot = zeros(number_of_neighbours,number_of_msdus-1);
    %matrix_tmt_backoff_birthday_problem_plot = zeros(number_of_neighbours,number_of_msdus-1);
    for n=1:1:number_of_rates
        for t=2:1:number_of_msdus
            for z=1:1:number_of_neighbours
                matrix_tmt_collisions_percent_plot(z,t-1) = matrix_tmt_collisions_percent(n,t,z);
                %matrix_tmt_backoff_birthday_problem_plot(z,t-1)= matrix_tmt_backoff_birthday_problem(n,t,z);  
            end
        end
        figure(next_figure_number)
        hold all
        vector_number_of_neighbours = 1:1:number_of_neighbours;
        plot(vector_number_of_neighbours,matrix_tmt_collisions_percent_plot)
        %plot(vector_number_of_neighbours,matrix_tmt_backoff_birthday_problem_plot,'-x')  
        grid on
        xlabel('Anzahl Nachbarn');
        ylabel('Kollisionen[percent]');
        title_string = sprintf('Datenrate = %f Mbps',vector_rates(1,n));
        title(title_string)
        legend_txt  =cell(1,number_of_msdus-1);
        for i = 2:1:number_of_msdus
            string = num2str(vector_msdu(1,i));
            legend_txt(1,i-1) = {string};
        end
        hl_2= legend(legend_txt,'Location','EastOutside');
        set(get(hl_2,'title'),'String',{sprintf('MSDU-Größe [Bytes]')})
        hold off
        next_figure_number = next_figure_number + 1;
    end
end
    
    next_figure_number = 1;

    


        %-------------------------------------------------------------
        
            next_figure_number = next_figure_number+ 1;
    [number_of_rates,number_of_msdus,number_of_neighbours] =size(matrix_tmt_collisions_percent);
    matrix_tmt_collisions_percent_plot_3 = zeros(number_of_neighbours,1);
    matrix_tmt_backoff_birthday_problem_plot_3 = zeros(number_of_neighbours,1);
    %t = 4; % MSDU-Size = 1500 Byte
    %n = number_of_rates; %Rate = max Rate
    %for n=1:1:number_of_rates
        %for t=2:1:number_of_msdus
        t = 200; % Backoff-window size
            for n=1:1:number_of_neighbours
                if (matrix_collision(n,t) == 0)
                   matrix_tmt_collisions_percent_plot_3(n,1) = 100;
                else
                    %(vector_number_of_collisions_2(n,1) / (vector_number_of_collisions(n,1) + 100)) * 100; %[percent]
                    matrix_tmt_collisions_percent_plot_3(n,1) = (matrix_collision(n,t) / (matrix_collision(n,t) + 100)) * 100; % [percent]
                end
                matrix_tmt_backoff_birthday_problem_plot_3(n,1)= matrix_birthday_problem_collision_likelihood_packet_loss(n,t) * 100;  %[percent]
         %   end
            end
        figure(next_figure_number)
        %hold all
        %vector_number_of_neighbours = 1:1:number_of_neighbours;
        plot(matrix_tmt_backoff_birthday_problem_plot_3,matrix_tmt_collisions_percent_plot_3,'x') 
        %plot(vector_number_of_neighbours,matrix_tmt_collisions_percent_plot)
        %plot(vector_number_of_neighbours,matrix_tmt_backoff_birthday_problem_plot,'x')  
        grid on
        xlabel('Kollisionen Calc [%]');
        ylabel('Kollisionen Sim [%]');
        
        next_figure_number = next_figure_number+ 1;
        figure(next_figure_number)
        plot(matrix_tmt_collisions_percent_plot_3,matrix_tmt_backoff_birthday_problem_plot_3,'x') 
        grid on
        xlabel('Kollisionen Sim  [%]');
        ylabel('Kollisionen Calc [%]');
        
        next_figure_number = next_figure_number+ 1;
        figure(next_figure_number)
         plot(matrix_tmt_collisions_percent_plot_3,matrix_tmt_backoff_birthday_problem_plot_3,'x') 
        grid on
        xlabel('Anazhl Kollisionen Sim');
        ylabel('Anazhl Kollisionen Calc');
        %----------------------------------------------------------------
        next_figure_number = next_figure_number+ 1;
        
        matrix_tmt_backoff_window_slots_plot = zeros(number_of_neighbours,1);
        matrix_tmt_backoff_window_slots_birthday_problem_app_plot = zeros(number_of_neighbours,1);
        %matrix_tmt_backoff_birthday_problem_approximation = zeros(size(vector_rates,2),size(vector_msdu,2),no_neighbours_max);
        index_msdu_size = 4; % MSDU-Size = 1500 Byte
        index_rate = number_of_rates; %Rate = max Rate
        for n=1:1:number_of_neighbours
                matrix_tmt_backoff_window_slots_plot(n,1) = matrix_tmt_backoff(index_rate,index_msdu_size,n); 
                matrix_tmt_backoff_window_slots_birthday_problem_app_plot(n,1)= matrix_tmt_backoff_birthday_problem_approximation(index_rate,index_msdu_size,n);  
        end
        figure(next_figure_number)
        plot(matrix_tmt_backoff_window_slots_plot,matrix_tmt_backoff_window_slots_birthday_problem_app_plot,'x') 
        grid on
        xlabel('Backoff-Window-Size Sim [slots]');
        ylabel('Backoff-Window-Size Approx. [slots]');
        title_string = sprintf('Datenrate = %f Mbps',vector_rates(1,index_rate));
        title(title_string)
        legend_txt  =cell(1,1);
        %for i = 2:1:number_of_msdus
            string = num2str(vector_msdu(1,index_msdu_size));
            legend_txt(1,1) = {string};
        %end
        hl_2= legend(legend_txt,'Location','EastOutside');
        set(get(hl_2,'title'),'String',{sprintf('MSDU-Größe [Bytes]')})
        
        next_figure_number = next_figure_number+ 1;
        figure(next_figure_number)
        plot(matrix_tmt_backoff_window_slots_birthday_problem_app_plot,matrix_tmt_backoff_window_slots_plot,'x') 
        grid on
        xlabel('Backoff-Window-Size Approx. [slots]');
        ylabel('Backoff-Window-Size Sim [slots]');
        title_string = sprintf('Datenrate = %f Mbps',vector_rates(1,index_rate));
        title(title_string)
        legend_txt  =cell(1,1);
        %for i = 2:1:number_of_msdus
            string = num2str(vector_msdu(1,index_msdu_size));
            legend_txt(1,1) = {string};
        %end
        hl_2= legend(legend_txt,'Location','EastOutside');
        set(get(hl_2,'title'),'String',{sprintf('MSDU-Größe [Bytes]')})
    
 end   
output_args = 1;
end

