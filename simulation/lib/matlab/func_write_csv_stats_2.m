function  func_write_csv_stats_2(folder_name, matrix_results_counter_round_global_packet_delivered, matrix_results_counter_round_global_packet_collided,matrix_results_counter_slots_global)    
    filename_xml_1 = sprintf('%s/sim_counter_round_global_packet_delivered',folder_name);
    filename_xml_2 = sprintf('%s/sim_counter_round_global_packet_collided',folder_name);
    filename_xml_3 = sprintf('%s/sim_counter_slots_global',folder_name);
    func_csvwrite_matrix_3D_2(filename_xml_1,matrix_results_counter_round_global_packet_delivered)
    func_csvwrite_matrix_3D_2(filename_xml_2,matrix_results_counter_round_global_packet_collided)
    func_csvwrite_matrix_3D_2(filename_xml_3,matrix_results_counter_slots_global)    
end



