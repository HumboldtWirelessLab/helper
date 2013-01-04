function [retries_min_mean_neighbours,retries_max_mean_neighbours, retries_avg_mean_neighbours] = func_statistics_calc_retries(retries_min,retries_max,retries_avg,retries_avg_counter,counter_retries_min_frequencies,counter_retries_max_frequencies)
    retries_min_mean_neighbours = mean(retries_min);

    retries_max_mean_neighbours = mean(retries_max);
    retries_avg_mean = zeros(1,size(retries_avg,2));
    for r = 1:1:size(retries_avg,2)
        retries_avg_mean(1,r) = retries_avg(1,r) / retries_avg_counter(1,r);
    end
    retries_avg_mean_neighbours = mean(retries_avg_mean);

end

