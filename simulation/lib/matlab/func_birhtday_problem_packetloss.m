function [likelihood_packet_loss] = func_birhtday_problem_packetloss(vector_neighbours,vector_backoff)
%function [table_neighbours,table_backoff_windows,likelihood] = func_birhtday_problem_packetloss(vector_neighbours,vector_backoff)
%-------------------Initialisiere Variablen--------------------------------
    product_term = 1;
    number_of_backoff_window_sizes = max(vector_backoff);
    number_of_neighbours_sizes = max(vector_neighbours);
    likelihood_packet_loss=zeros(number_of_neighbours_sizes,number_of_backoff_window_sizes);
    counter = 1;
    counter2 = 1;
%--------------------------------------------------------------------------
    neighbours_max = max(vector_neighbours);
    counter_nieghobur_add = max(vector_neighbours) + 1;
    neighbours_max =  neighbours_max + 1;
    for i=1:1:number_of_backoff_window_sizes
        if (~isempty(find(vector_backoff == i, 1)))    
            for k=1:1:neighbours_max
                if (i > 0)
                    product_term = (product_term * ((i - k + 1)/i));
                    if ((~isempty(find(vector_neighbours == k, 1)) || counter_nieghobur_add == k ) && k > 1)
                     if ( 1 - product_term ~= 1)
                        likelihood_packet_loss(counter2,counter) = 1 - product_term;
                     end
                        counter2 = counter2 + 1;
                    end
                end
            end
            counter = counter + 1;
            counter2 = 1;
        end
        product_term = 1;
    end
end

