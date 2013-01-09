function [criterion_termination] = func_backoff_calculation_terminate_global(packets_delivery_counter_global,packet_delivery_limit)
    criterion_termination = 0;
    if (packets_delivery_counter_global < packet_delivery_limit)
        criterion_termination = 1;
    end
end

