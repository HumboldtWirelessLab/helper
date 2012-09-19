% Function calculate an approximation of the backoff-window-slots with the mean of the Birthday-Problem
% assumption: (1 -x ) = e^(-x)
% @params vector_packet_loss            -   different packetloss likelihoods
%         vector_neighbours             -   different number of neighbours
% @return backoff_windows_slot_approximation  -   backoff_windows_slots for
%                                             different packetlosses and number of neighbours
function [backoff_windows_slot_approximation] = func_backkoff_approximation(vector_packet_loss,vector_neighbours)
w_approximate_all = zeros(size(vector_packet_loss,2),size(vector_neighbours,2));
backoff_windows_slot_approximation = zeros(size(vector_packet_loss,2),size(vector_neighbours,2));
number_of_neighbours_max = max(vector_neighbours);
table_neighbours = zeros(1,number_of_neighbours_max);
counter = 1;
counter_2=1;
for i =1:1:size(vector_packet_loss,2)
    pc = vector_packet_loss(1,i);
    for j=1:1:number_of_neighbours_max
        if ((2*log(1-pc)) ~= 0)
            w_approximate_all(i,counter) = (-1) * (j * (j - 1))/(2*log(1-pc));
            if (~isempty(find(vector_neighbours == j, 1))) 
                backoff_windows_slot_approximation(i,counter_2) = ceil(w_approximate_all(i,counter)); %there are only int slots, for that reason round up
                counter_2 = counter_2 + 1;
            end
            table_neighbours(1,counter) = j;
            counter = counter + 1;
        end
    end
    counter = 1;
    counter_2 = 1;
end

end



