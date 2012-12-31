function func_figure_comparison_2(figure_number,matrix_simulation_collision,matrix_birthday_problem_collision_likelihood_packet_loss)
%[number_of_rates,number_of_msdus,number_of_neighbours] =size(matrix_tmt_collisions_percent);
    [number_of_neighbours_max] = size(matrix_simulation_collision,1);
    vector_backoff = [100,250,1000, 2000,3000];
    matrix_tmt_collisions_percent_plot_3 = zeros(number_of_neighbours_max,size(vector_backoff,2));
    matrix_tmt_backoff_birthday_problem_plot_3 = zeros(number_of_neighbours_max,size(vector_backoff,2));
    
    %t = 4; % MSDU-Size = 1500 Byte
    %n = number_of_rates; %Rate = max Rate
    %for n=1:1:number_of_rates
        %for t=2:1:number_of_msdus
         for t =1:1:size(vector_backoff,2); % Backoff-window size
         %t = 200;
            for n=1:1:number_of_neighbours_max
                if (matrix_simulation_collision(n,vector_backoff(1,t)) == 0)
                   matrix_tmt_collisions_percent_plot_3(n,t) = 100;
                else
                    %(vector_number_of_collisions_2(n,1) / (vector_number_of_collisions(n,1) + 100)) * 100; %[percent]
                    matrix_tmt_collisions_percent_plot_3(n,t) = (matrix_simulation_collision(n,vector_backoff(1,t)) / (matrix_simulation_collision(n,vector_backoff(1,t)) + 100)) * 100; % [percent]
                end
                matrix_tmt_backoff_birthday_problem_plot_3(n,t)= matrix_birthday_problem_collision_likelihood_packet_loss(n,vector_backoff(1,t)) * 100;  %[percent]
            end
         end

        figure(figure_number)
        %hold all
        %vector_number_of_neighbours = 1:1:number_of_neighbours;
        plot(matrix_tmt_backoff_birthday_problem_plot_3,matrix_tmt_collisions_percent_plot_3,'-x')
        %plot(vector_number_of_neighbours,matrix_tmt_collisions_percent_plot)
        %plot(vector_number_of_neighbours,matrix_tmt_backoff_birthday_problem_plot,'x')  
        grid on
        xlabel('Kollisionen Calc [%]');
        ylabel('Kollisionen Sim [%]');
        set(gca,'FontSize',10,'fontweight','bold')
        %figure_number = figure_number+ 1;
        %figure(figure_number)
        %plot(matrix_tmt_collisions_percent_plot_3,matrix_tmt_backoff_birthday_problem_plot_3,'x')
        %grid on
        %xlabel('Kollisionen Sim  [%]');
        %ylabel('Kollisionen Calc [%]');

        %figure_number = figure_number+ 1;
        %figure(figure_number)
        % plot(matrix_tmt_collisions_percent_plot_3,matrix_tmt_backoff_birthday_problem_plot_3,'x')
        %grid on
        %xlabel('Anazhl Kollisionen Sim');
        %ylabel('Anazhl Kollisionen Calc');


end

