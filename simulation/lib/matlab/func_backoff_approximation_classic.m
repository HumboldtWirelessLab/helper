% Function calculate an approximation of the backoff-window-slots with the mean of the Birthday-Problem
% assumption: (1 -x ) = e^(-x)
% @params vector_packet_loss            -   different packetloss likelihoods
%         vector_neighbours             -   different number of neighbours
% @return backoff_windows_slot_approximation  -   backoff_windows_slots for
%                                             different packetlosses and number of neighbours
function [matrix_packet_loss_neighbours_backoff_windows_approximation] = func_backoff_approximation_classic(vector_packet_loss,vector_neighbours)
    matrix_w_approximate_all = zeros(size(vector_packet_loss,2),size(vector_neighbours,2));
    matrix_packet_loss_neighbours_backoff_windows_approximation = zeros(size(vector_packet_loss,2),size(vector_neighbours,2));
    number_of_neighbours_max = max(vector_neighbours);
    %number_of_neighbours_sizes_min = min(vector_neighbours);
    %vector_result_neighbours = zeros(1,number_of_neighbours_max);
    %number_of_neighbours_sizes_min = min(vector_neighbours);
    counter = 0;
    %counter_2=0;
    %counter_neighbours_add = number_of_neighbours_max + 1;
    %number_of_neighbours_max = number_of_neighbours_max + 1;
    for i =1:1:size(vector_packet_loss,2)
        pc = vector_packet_loss(1,i);
        counter = counter + 1;
        counter_2 = 0;
        %for j=1:1:number_of_neighbours_max + 1
        for j=1:1:number_of_neighbours_max
            if (pc > 0)
                
                
                matrix_w_approximate_all(counter,j) = (-1) * (j * (j + 1))/(2*log(1-pc));
                
                if ((~isempty(find(vector_neighbours == j, 1)))) % || counter_neighbours_add == j)) % && j > 1)
                    counter_2 = counter_2 + 1;
                    matrix_packet_loss_neighbours_backoff_windows_approximation(counter,counter_2) = ceil(matrix_w_approximate_all(counter,counter_2)); %there are only int slots, for that reason round up
                    
                end
                %vector_result_neighbours(1,counter_2) = j;
                %counter = counter + 1;
            end
        end
        %counter_2 = 1;
        %counter = 0;
    end
end