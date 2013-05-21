function [matrix_likelihood_collisions] = func_sim_mean_globlal_calculation(matrix_2D, matrix_packets_successful_delivered)
    matrix_likelihood_collisions = zeros(size(matrix_2D,1),size(matrix_2D,2));
    for t=1:1:size(matrix_2D,1)
        for z=1:1:size(matrix_2D,2)
            if (matrix_2D(t,z) + matrix_packets_successful_delivered(t,z) > 0)
                matrix_likelihood_collisions(t,z) = matrix_2D(t,z) / (matrix_2D(t,z) + matrix_packets_successful_delivered(t,z));
            end
        end
    end   
end


