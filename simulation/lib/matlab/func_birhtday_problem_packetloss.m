function [likelihood_packet_loss] = func_birhtday_problem_packetloss(vector_backoff,vector_neighbours)
%-------------------Initialisiere Variablen--------------------------------
    number_of_backoff_window_sizes_min = min(vector_backoff);
    number_of_backoff_window_sizes_max = max(vector_backoff);
    number_of_neighbours_sizes_min = min(vector_neighbours);
    number_of_neighbours_sizes_max = max(vector_neighbours);
    likelihood_packet_loss=zeros(size(vector_neighbours,2),size(vector_backoff,2));
    counter = 0;
%--------------------------------------------------------------------------
    for i=number_of_backoff_window_sizes_min:1:number_of_backoff_window_sizes_max
        if (~isempty(find(vector_backoff == i, 1)))
            counter = counter + 1;
            counter2 = 1;
            for k=number_of_neighbours_sizes_min:1:number_of_neighbours_sizes_max
                if (~isempty(find(vector_neighbours == k, 1)))
                    if (i > 0 && k > 0)
                        likelihood_packet_loss(counter2,counter) = 1 - ((i-1) / i)^k;
                        counter2 = counter2 + 1;
                    else
                        if ( i > 0 && k == 0) % if cw > 0 and #neighbours == 0
                            likelihood_packet_loss(counter2,counter) = 0; % there is not a collision
                            counter2 = counter2 + 1;
                        elseif (i == 0 && k == 0)  % if cw == 0 and #neighbours == 0
                            likelihood_packet_loss(counter2,counter) = 0; % there is not a collision
                            counter2 = counter2 + 1;                  
                        elseif (i == 0 && k > 0)  % if cw == 0 and #neighbours > 0
                            likelihood_packet_loss(counter2,counter) = 1; % there are every time collisions, because every station wants to send every time
                            counter2 = counter2 + 1;
                        end
                    end  
                end
            end
        end        
    end
end

