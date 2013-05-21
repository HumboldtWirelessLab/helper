% Function calculate an approximation of the backoff-window-slots with the mean of the Birthday-Problem
% assumption: (1 -x ) = e^(-x)
% @params vector_packet_loss            -   different packetloss likelihoods
%         vector_neighbours             -   different number of neighbours
% @return backoff_windows_slot_approximation  -   backoff_windows_slots for
%                                             different packetlosses and number of neighbours
function [matrix_packet_loss_neighbours_backoff_windows_approximation] = func_backoff_approximation_3(vector_packet_loss,vector_neighbours)
    matrix_w_approximate_all = zeros(size(vector_packet_loss,2),size(vector_neighbours,2));
    matrix_packet_loss_neighbours_backoff_windows_approximation = zeros(size(vector_packet_loss,2),size(vector_neighbours,2));
    number_of_neighbours_max = max(vector_neighbours);
    vector_result_neighbours = zeros(1,number_of_neighbours_max);
    number_of_neighbours_sizes_min = min(vector_neighbours);
    counter = 1;
    counter_2=1;
    %counter_neighbours_add = number_of_neighbours_max + 1;
    %number_of_neighbours_max = number_of_neighbours_max + 1;
    for i =1:1:size(vector_packet_loss,2)
        pc = vector_packet_loss(1,i);
        for j=number_of_neighbours_sizes_min:1:number_of_neighbours_max 
            if (pc > 0)
                matrix_w_approximate_all(i,counter) = 1/(1 - (1-pc)^(1/((j+1)-1)));
                if ((~isempty(find(vector_neighbours == j, 1)))) %|| counter_neighbours_add == j) && j > 1) 
                    %if (matrix_w_approximate_all(i,counter) >= 0)
                        matrix_packet_loss_neighbours_backoff_windows_approximation(i,counter_2) = matrix_w_approximate_all(i,counter); %there are only int slots, for that reason round up
                        counter_2 = counter_2 + 1;
                    %end
                end
                vector_result_neighbours(1,counter) = j;
                counter = counter + 1;
            end
        end
        counter = 1;
        counter_2 = 1;
    end
end

