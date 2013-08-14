%% * This function calculate the air_capacity (theoretic max. thourghput; TMT) and the bandwidth efficiency 
% * see Paper Jangeun Jun, Pushkin Peddabachagari, Mihail Sichitiu; "Theoretical Maximum Throughput of IEEE 802.11 and its Applications"
% @params   phy_rate_basic             -  lowest physical rate for the current standard, used for calculate bandwidth efficiency [bps]
%           matrix_number_of_packets_delivered  - how many packets were received by the receiving station
%           msdu_size                    - MSDU size in [byte]
%           delay_per_msdu_successful   - if a frame-transmission was succefull 
%           delay_per_msdu_unsuccessful - if a frame-transmission ws unsuccessful( collision has occurred)
%           time_slot                    - Backoff-Slot-time in [sec] (depend of the Standards)
%           matrix_number_of_slots       - Average Number of slots were needed for frame transmission per[number_of_neighbours,backoff_window_size]   
%           matrix_number_of_collision   - Average Number of collision were - needed for frame transmission per[number_of_neighbours,backoff_window_size] 
% @return   matrix_air_capacity          - TMT for different neighbours and backoff_window_sizes [Mbps]
%           matrix_efficiency            - Bandwidth efficiency for
%           different neighbours and backoff_window_sizes [percent] (depend of the basic phy rate)
%%
function [matrix_air_capacity, matrix_efficiency ] = func_calculation_air_capacity_efficiency(phy_rate_basic,matrix_number_of_packets_delivered,msdu_size,delay_per_msdu_successful,delay_per_msdu_unsuccessful, time_slot, matrix_number_of_slots, matrix_number_of_collision)
    byte = 8; %[bits]
    kbps = 1000;%[bit/second] Umrechnungsfaktor := 1 Mb/s (Mbps) = 1000 kb/s
    Mbps = kbps * 1000;%[bit/second] Umrechnungsfaktor := 1 Mb/s (Mbps) = 1000 kb/s = 1000000 Bit/seconds
    matrix_air_capacity = zeros(size(matrix_number_of_collision,1),size(matrix_number_of_collision,2));
    matrix_efficiency = zeros(size(matrix_number_of_collision,1),size(matrix_number_of_collision,2));
    for i = 1:1:size(matrix_number_of_collision,1)
        for j = 1:1:size(matrix_number_of_collision,2)
            time_backoff = matrix_number_of_slots(i,j)  * time_slot; %[sec] slot_time_duration for the backoff included als slot times for retries, if a frame had collided
            time_packets_collision =  matrix_number_of_collision(i,j) * delay_per_msdu_unsuccessful; %[sec] time of a duration, when a frame had collided, because a 802.11-Station had to send the whole frame and wait then for an reply
            time_packets_delivery = matrix_number_of_packets_delivered(i,j) * delay_per_msdu_successful; %[sec] total time of successful transmission of different packets
            if ((time_backoff == 0) && (time_packets_collision == 0))
                time_packets_duration = 0;
            else
                time_packets_duration = time_backoff + time_packets_collision +  time_packets_delivery;%[sec]
            end
            % 4. Air capacity; also defined as Theoretical Maximum Throughput(TMT)
            % TMT = MSDU_size / delay_per_msdu
            if (time_packets_duration == 0)
                matrix_air_capacity(i,j) = 0;
            else
                matrix_air_capacity(i,j) = ((matrix_number_of_packets_delivered(i,j) * (msdu_size * byte)) / time_packets_duration)/Mbps; %[Mbps]
            end
            % 5. Calc efficiency (bandwidth efficiency)
            matrix_efficiency(i,j) = (matrix_air_capacity(i,j) / phy_rate_basic); %[percent]
        end
    end
end

