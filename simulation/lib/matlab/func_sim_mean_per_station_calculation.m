function [matrix_likelihood_collisions] = func_sim_mean_per_station_calculation(matrix,packets_successful_delivered)
    matrix_likelihood_collisions = zeros(size(matrix,1),size(matrix,2),size(matrix,3));
    for p=1:1:size(matrix,3)
        for t=1:1:size(matrix,2)
            for z=1:1:size(matrix,1)
                matrix_likelihood_collisions(z,t,p) = matrix(z,t,p) / (matrix(z,t,p) + packets_successful_delivered);
            end
        end
    end
end

