function packet_stat_print(packet_stat_file)

load(packet_stat_file);

fprintf(1,'measurement_duration: %f\n',end_time-start_time);
fprintf(1,'packet_interval: %f\n',mean_packet_interval);
fprintf(1,'packet_interval_std: %f\n',std_packet_interval);
fprintf(1,'own_send_packets: %f\n',count_send_packets);
fprintf(1,'own_rec_packets_all: %f\n',size(own_packets,1));
fprintf(1,'own_rec_packets_ok: %f\n',size(own_packets_ok,1));
fprintf(1,'own_rec_packets_ok_bin_sum: %f\n',sum(bin_own_packet_count));
fprintf(1,'own_rec_packets_ok_bin_mean: %f\n',mean(bin_own_packet_count));
fprintf(1,'own_rec_packets_ok_bin_std: %f\n',std(bin_own_packet_count));
fprintf(1,'own_rec_packets_crc: %f\n',size(own_packets_crc,1));
fprintf(1,'own_rec_packets_phy: %f\n',size(own_packets_phy,1));
fprintf(1,'own_per_mean: %f\n',per);
fprintf(1,'own_per_bin_mean: %f\n',mean_bin_per);
fprintf(1,'own_per_bin_std: %f\n',std_bin_per);
fprintf(1,'own_rssi_mean: %f\n',mean_rssi);
fprintf(1,'own_rssi_std: %f\n',std_rssi);
fprintf(1,'percentile_rssi_5: %f\n',prctile_rssi(1));
fprintf(1,'percentile_rssi_25: %f\n',prctile_rssi(2));
fprintf(1,'percentile_rssi_50: %f\n',prctile_rssi(3));
fprintf(1,'percentile_rssi_75: %f\n',prctile_rssi(4));
fprintf(1,'percentile_rssi_95: %f\n',prctile_rssi(5));
fprintf(1,'ghost_rec_packets_all: %f\n',count_ghost_packets);
fprintf(1,'for_rec_packets_all: %f\n',count_for_packets);
fprintf(1,'for_rssi_mean: %f\n',mean_forrssi);
fprintf(1,'for_rssi_std: %f\n',std_forrssi);
fprintf(1,'percentile_forrssi_5: %f\n',prctile_forrssi(1));
fprintf(1,'percentile_forrssi_25: %f\n',prctile_forrssi(2));
fprintf(1,'percentile_forrssi_50: %f\n',prctile_forrssi(3));
fprintf(1,'percentile_forrssi_75: %f\n',prctile_forrssi(4));
fprintf(1,'percentile_forrssi_95: %f\n',prctile_forrssi(5));


clear;

end

