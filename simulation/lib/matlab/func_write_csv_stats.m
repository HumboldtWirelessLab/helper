function func_write_csv_stats(matrix_results_packets_delivery_counter_global,matrix_results_counter_slots_global,matrix_results_collision_avg,matrix_results_collision_min,matrix_results_collision_min_counter,matrix_results_collision_max,matrix_results_collision_max_counter,matrix_results_retries_avg,matrix_results_retries_min,matrix_results_retries_min_counter,matrix_results_retries_max,matrix_results_retries_max_counter)
    filename_xml_1 = 'sim_packets_delivery_counter_global.csv';
    filename_xml_2 = 'sim_counter_slots_global.csv';
    filename_xml_3 ='sim_collision_avg.csv';
    filename_xml_4 ='sim_collision_min.csv';
    filename_xml_5 ='sim_collision_min_counter.csv';
    filename_xml_6 = 'sim_collision_max.csv';
    filename_xml_7 = 'sim_collision_max_counter.csv';
    
    filename_xml_8 = 'sim_retries_avg.csv';
    filename_xml_9 = 'sim_retries_min.csv';
    filename_xml_10 = 'sim_retries_min_counter.csv';
    filename_xml_11 = 'sim_retries_max.csv';
    filename_xml_12 = 'sim_retries_max_counter.csv';

    
    csvwrite(filename_xml_1,matrix_results_packets_delivery_counter_global) 
    csvwrite(filename_xml_2 ,matrix_results_counter_slots_global) 
    csvwrite(filename_xml_3,matrix_results_collision_avg)
    csvwrite(filename_xml_4,matrix_results_collision_min)
    csvwrite(filename_xml_5,matrix_results_collision_min_counter)
    
    csvwrite(filename_xml_6,matrix_results_collision_max)
    csvwrite(filename_xml_7,matrix_results_collision_max_counter)
    
    csvwrite(filename_xml_8,matrix_results_retries_avg)
    csvwrite(filename_xml_9,matrix_results_retries_min)
    csvwrite(filename_xml_10,matrix_results_retries_min_counter)
    
    csvwrite(filename_xml_11,matrix_results_retries_max)
    csvwrite(filename_xml_12,matrix_results_retries_max_counter)
end

