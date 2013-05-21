function [matrix_likelihood_collisions] = func_sim_mean_per_station_calculation_3D(matrix, matrix_packets_successful_delivered)
    matrix_likelihood_collisions = zeros(size(matrix,1),size(matrix,2),size(matrix,3));
    for p=1:1:size(matrix,1)
        for t=1:1:size(matrix,2)
            for z=1:1:size(matrix,3)
                if (matrix(p,t,z) + matrix_packets_successful_delivered(p,t,z) > 0)
                    matrix_likelihood_collisions(p,t,z) = matrix(p,t,z) / (matrix(p,t,z) + matrix_packets_successful_delivered(p,t,z));
                end
            end
        end
    end
end


