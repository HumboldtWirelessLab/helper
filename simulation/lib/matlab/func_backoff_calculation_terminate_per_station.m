function [criterion_termination] = func_backoff_calculation_terminate_per_station(vector_packets_delivered_per_station,packet_delivery_limit)
    criterion_termination = 1;
    counter = 0;
    for i=1:1:size(vector_packets_delivered_per_station,2)
        if (vector_packets_delivered_per_station(1,i) >= packet_delivery_limit)
            counter = counter + 1;
        end
    end
    if (counter == size(vector_packets_delivered_per_station,2))
        criterion_termination = 0;
    end
end


