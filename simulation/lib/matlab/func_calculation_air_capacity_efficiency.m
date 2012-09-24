% * This function calculate the air_capacity (theoretic max. thourghput; TMT) and the bandwidth efficiency 
% * see Paper Jangeun Jun, Pushkin Peddabachagari, Mihail Sichitiu; "Theoretical Maximum Throughput of IEEE 802.11 and its Applications"
% @params   phy_rate_current             -  current physical rate, used for calculate bandwidth efficiency [bps]
%           number_of_packets_delivered  - how many packets were received by the receiving station
%           msdu_size                    - MSDU size in [byte]
%           delay_per_msdu_without_ack   - if a frame had collied, there is not an ack-frame
%           delay_per_msdu_with_ack      - if a frame-transmission was succefull
%           slot_time                    - Backoff-Slot-time in [sec] (depend of the Standards)
%           matrix_number_of_slots       - Average Number of slots were needed for frame transmission per[number_of_neighbours,backoff_window_size]   
%           matrix_number_of_collision   - Average Number of collision were - needed for frame transmission per[number_of_neighbours,backoff_window_size] 
% @return   matrix_air_capacity          - TMT for different neighbours and backoff_window_sizes [Mbps]
%           matrix_efficiency            - Bandwidth efficiency for
%           different neighbours and backoff_window_sizes [percent] (depend of the basic phy rate)
function [matrix_air_capacity, matrix_efficiency ] = func_calculation_air_capacity_efficiency(phy_rate_current,number_of_packets_delivered,msdu_size,delay_per_msdu_without_ack, delay_per_msdu_with_ack, slot_time, matrix_number_of_slots, matrix_number_of_collision)
    byte = 8; %[bits]
    kb = 1000;%[byte]   
    Mb = kb * 1000;%[byte]
    
    [number_of_neighbours, backoff_window_size_max] = size(matrix_number_of_collision);
    matrix_air_capacity = zeros(number_of_neighbours,backoff_window_size_max);
    matrix_efficiency = zeros(number_of_neighbours,backoff_window_size_max);
    for i = 1:1:number_of_neighbours
        for j = 1:1:backoff_window_size_max
            time_backoff = matrix_number_of_slots(i,j)  * slot_time; %[sec] slot_time_duration for the backoff included als slot times for retries, if a frame had collided
            time_packets_collision =  matrix_number_of_collision(i,j) * delay_per_msdu_without_ack; %[sec] time of a duration, when a frame had collided, because a 802.11-Station had to send the whole frame and wait then for an reply
            time_packets_delivery = number_of_packets_delivered * delay_per_msdu_with_ack; %[sec] total time of successful transmission of different packets
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
                matrix_air_capacity(i,j) = ((number_of_packets_delivered * (msdu_size * byte)) / time_packets_duration)/Mb; %[bps]
            end
            % 5. Calc efficiency (bandwidth efficiency)
            matrix_efficiency(i,j) = (matrix_air_capacity(i,j) / phy_rate_current) * 100; %[percent]
        end
    end
end

