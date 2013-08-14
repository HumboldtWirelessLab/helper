function [likelihood_packet_loss] = func_birhtday_problem_packetloss_2(vector_backoff,vector_neighbours)
%-------------------Initialisiere Variablen--------------------------------
    number_of_backoff_window_sizes_min = min(vector_backoff);
    number_of_backoff_window_sizes_max = max(vector_backoff);
    number_of_neighbours_sizes_min = min(vector_neighbours);
    number_of_neighbours_sizes_max = max(vector_neighbours);
    likelihood_packet_loss=zeros(size(vector_neighbours,2),size(vector_backoff,2));
    counter = 0;
    %if (number_of_neighbours_sizes_min == 0)
    %    counter = counter + 1;
    %end
%--------------------------------------------------------------------------
    for i=number_of_backoff_window_sizes_min:1:number_of_backoff_window_sizes_max
        if (~isempty(find(vector_backoff == i, 1)))
            %if (i > 0)
            %    counter = counter + 1;
            %end
            %if (number_of_backoff_window_sizes_min == 0)
            %    counter2 = 1;
            %else
                %counter2 = 0;
                %if (number_of_neighbours_sizes_min == 0 && i > 0)
                %    counter2 = counter2 + 1;
                %end
            %end
            %if (~isempty(find(vector_backoff == i, 1)))
                counter = counter + 1;
                counter2 = 0;
                for k=number_of_neighbours_sizes_min:1:number_of_neighbours_sizes_max
                    if (~isempty(find(vector_neighbours == k, 1)))
                        counter2 = counter2 + 1;
                        if (i > 0)

                            
                            likelihood_packet_loss(counter2,counter) = 1 - ((i-1) / i)^(k);% 1 - ((365-1) / (365))^(251.652+1)
                        
                        else
                        %if ( i > 0 && k == 0) % if cw > 0 and #neighbours == 0
                        %    counter2 = counter2 + 1;
                        %    likelihood_packet_loss(counter2,counter) = 0; % there is not a collision                           
                        %else
                            if (~isempty(find(vector_neighbours == k, 1)))
                                if (i == 0 && k == 0)  % if cw == 0 and #neighbours == 0
                                    %counter2 = counter2 + 1;
                                    likelihood_packet_loss(counter2,counter) = 0; % there is not a collision                                             
                                elseif (i == 0 && k > 0)  % if cw == 0 and #neighbours > 0
                                    %counter2 = counter2 + 1;
                                    likelihood_packet_loss(counter2,counter) = 1; % there are every time collisions, because every station wants to send every time
                                end
                            end
                        end  
                    end
                end
            %end
        end        
    end
end
