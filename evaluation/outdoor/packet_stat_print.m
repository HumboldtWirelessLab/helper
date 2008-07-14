function packet_stat_print(packet_stat_file)

load(packet_stat_file);

fprintf(1,'duration: %f\n',end_time-start_time);
fprintf(1,'Interval: %f\n',mean_packet_interval);
fprintf(1,'Interval_std: %f\n',std_packet_interval);
fprintf(1,'send_packets: %f\n',count_send_packets);
fprintf(1,'all_rec_packets: %f\n',size(own_packets,1));
fprintf(1,'ok_packets: %f\n',size(own_packets_ok,1));
fprintf(1,'send_bin_packets: %f\n',sum(bin_own_packet_count));
fprintf(1,'mean_packets: %f\n',mean(bin_own_packet_count));
fprintf(1,'std_packets: %f\n',std(bin_own_packet_count));
fprintf(1,'crc_packets: %f\n',size(own_packets_crc,1));
fprintf(1,'phy_packets: %f\n',size(own_packets_phy,1));
fprintf(1,'per: %f\n',per);
fprintf(1,'mean_bin_per: %f\n',mean_bin_per);
fprintf(1,'std_bin_per: %f\n',std_bin_per);
fprintf(1,'mean_rssi: %f\n',mean_rssi);
fprintf(1,'std_rssi: %f\n',std_rssi);
fprintf(1,'percentile_rssi_5: %f\n',prctile_rssi(1));
fprintf(1,'percentile_rssi_25: %f\n',prctile_rssi(2));
fprintf(1,'percentile_rssi_50: %f\n',prctile_rssi(3));
fprintf(1,'percentile_rssi_75: %f\n',prctile_rssi(4));
fprintf(1,'percentile_rssi_95: %f\n',prctile_rssi(5));
fprintf(1,'mean_forrssi: %f\n',mean_forrssi);
fprintf(1,'std_forrssi: %f\n',std_forrssi);
fprintf(1,'percentile_forrssi_5: %f\n',prctile_forrssi(1));
fprintf(1,'percentile_forrssi_25: %f\n',prctile_forrssi(2));
fprintf(1,'percentile_forrssi_50: %f\n',prctile_forrssi(3));
fprintf(1,'percentile_forrssi_75: %f\n',prctile_forrssi(4));
fprintf(1,'percentile_forrssi_95: %f\n',prctile_forrssi(5));


clear;

end

