function [likelihood_packet_loss] = func_birhtday_problem_packetloss_classic_2(vector_backoff,vector_neighbours)
%-------------------Initialisiere Variablen--------------------------------
    product_term = 1;
    number_of_backoff_window_sizes_min = min(vector_backoff);
    number_of_backoff_window_sizes_max = max(vector_backoff);
    number_of_neighbours_sizes_min = min(vector_neighbours);
    number_of_neighbours_sizes_max = max(vector_neighbours);
    likelihood_packet_loss=zeros(size(vector_neighbours,2),size(vector_backoff,2));
    counter = 0;
%--------------------------------------------------------------------------
    for i=number_of_backoff_window_sizes_min:1:number_of_backoff_window_sizes_max
        if (~isempty(find(vector_backoff == i, 1)))
            if (i >= 0)
                counter = counter + 1;
            end
            counter2 = 0;
            for k=number_of_neighbours_sizes_min:1:number_of_neighbours_sizes_max
                if (i > 0)
                    product_term = (product_term * ((i - (k + 1) + 1)/i));
                    if (~isempty(find(vector_neighbours == k, 1)))
                        counter2 = counter2 + 1;
                        likelihood_packet_loss(counter2,counter) = 1 - product_term;
                    end
                else 
                    counter2 = counter2 + 1;
                    likelihood_packet_loss(counter2,counter) = 1;
                end
            end
        end
        product_term = 1;
    end
end