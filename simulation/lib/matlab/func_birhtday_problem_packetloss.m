function [likelihood_packet_loss] = func_birhtday_problem_packetloss(vector_neighbours,vector_backoff)
%function [table_neighbours,table_backoff_windows,likelihood] = func_birhtday_problem_packetloss(vector_neighbours,vector_backoff)
%-------------------Initialisiere Variablen--------------------------------
    product_term = 1;
    number_of_backoff_window_sizes = length(vector_backoff);
    number_of_neighbours_sizes = length (vector_neighbours);
    likelihood_packet_loss=zeros(number_of_neighbours_sizes,number_of_backoff_window_sizes);
    %table_backoff_windows = zeros(1,number_of_backoff_window_sizes);
    %table_neighbours=zeros(1,number_of_backoff_window_sizes);
    counter = 1;
    counter2 = 1;
%--------------------------------------------------------------------------
    backoff_start_value = min(vector_backoff);
    backoff_step_size = 1;
    backoff_window_size = max(vector_backoff);
    neighbours_max = max(vector_neighbours);
    for i=backoff_start_value:backoff_step_size:backoff_window_size
        if (~isempty(find(vector_backoff == i, 1)))    
            for k=1:1:neighbours_max
                if (i > 0)
                    product_term = (product_term * ((i - k + 1)/i));
                    if (~isempty(find(vector_neighbours == k, 1)))
                        likelihood_packet_loss(counter2,counter) = 1 - product_term;
                        %table_neighbours(counter2,counter) = k;
                        counter2 = counter2 + 1;
                    end
                end
            end
            %table_backoff_windows(1,counter) = i;
            counter = counter + 1;
            counter2 = 1;
        end
        product_term = 1;
    end
end

