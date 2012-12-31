function [matrix_likelihood_collisions] = func_sim_mean_per_station_calculation(matrix, matrix_packets_successful_delivered,read_3D_on)
    matrix_likelihood_collisions = zeros(size(matrix,1),size(matrix,2),size(matrix,3));
    for p=1:1:size(matrix,3)
        for t=1:1:size(matrix,2)
            for z=1:1:size(matrix,1)
                if (read_3D_on == 1)
                    matrix_likelihood_collisions(z,t,p) = matrix(z,t,p) / (matrix(z,t,p) + matrix_packets_successful_delivered(z,t,p));
                else
                    matrix_likelihood_collisions(z,t,p) = matrix(z,t,p) / (matrix(z,t,p) + matrix_packets_successful_delivered(p,t));
                end
            end
        end
    end
end

