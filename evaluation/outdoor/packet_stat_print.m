function packet_stat_print(packet_stat_file)

load(packet_stat_file);

printf("duration: %f\n",end_time-start_time);
printf("Interval: %f\n",mean_packet_interval);
printf("Interval_std: %f\n",std_packet_interval);
printf("send_packets: %f\n",count_send_packets);
printf("all_rec_packets: %f\n",size(own_packets,1));
printf("ok_packets: %f\n",size(own_packets_ok,1));
printf("send_bin_packets: %f\n",sum(bin_own_packet_count));
printf("mean_packets: %f\n",mean(bin_own_packet_count));
printf("std_packets: %f\n",std(bin_own_packet_count));
printf("crc_packets: %f\n",size(own_packets_crc,1));
printf("phy_packets: %f\n",size(own_packets_phy,1));
printf("per: %f\n",per);
printf("mean_bin_per: %f\n",mean_bin_per);
printf("std_bin_per: %f\n",std_bin_per);
printf("mean_rssi: %f\n",mean_rssi);
printf("std_rssi: %f\n",std_rssi);
printf("percentile_rssi_5: %f\n",prctile_rssi(1));
printf("percentile_rssi_25: %f\n",prctile_rssi(2));
printf("percentile_rssi_50: %f\n",prctile_rssi(3));
printf("percentile_rssi_75: %f\n",prctile_rssi(4));
printf("percentile_rssi_95: %f\n",prctile_rssi(5));
printf("mean_forrssi: %f\n",mean_forrssi);
printf("std_forrssi: %f\n",std_forrssi);
printf("percentile_forrssi_5: %f\n",prctile_forrssi(1));
printf("percentile_forrssi_25: %f\n",prctile_forrssi(2));
printf("percentile_forrssi_50: %f\n",prctile_forrssi(3));
printf("percentile_forrssi_75: %f\n",prctile_forrssi(4));
printf("percentile_forrssi_95: %f\n",prctile_forrssi(5));


clear;

end

