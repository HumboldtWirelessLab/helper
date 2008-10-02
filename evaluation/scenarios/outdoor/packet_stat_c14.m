function packet_stat_c14(psize, bitrate, interval, packetfile,numbins,packet_stat_file)
% psize - Packetsize
% bitrate - Bitrate of own packets

FOREIGN=0;
OWN=1;
GHOST=2;

OK=0;
CRC=1;
PHY=2;

MIN_RSSI=-5;
MAX_FOREIGN_RATE = -1;

allpackets=load(packetfile);

allpackets( find( allpackets(:,7) > 100 ),7) = 0;                                                                  % remove wrong rssi

allpackets( find( ( allpackets(:,4) ~= psize ) & ( allpackets(:,3) == OWN ) ),3) = GHOST;   %all ghost, which are own but don't match to the given Packetsize
allpackets( find( ( allpackets(:,5) ~= bitrate ) & ( allpackets(:,3) == OWN ) ),3) = GHOST; %all ghost, which are own but don't match to the given Bitrate

%own packet with other bitrate/size are not foreign but lso not own, i call them ghost

own_packets = allpackets( find( allpackets(:,3) == OWN ),:);
%add stuff to correct

own_packets(:,6)=5 * own_packets(:,6);

ids=unique(own_packets(:,6));

for i=1:size(ids,1)
    subid=find(own_packets(:,6) == ids(i));
    for j=1:size(subid,1)
       own_packets(subid(j),6)=own_packets(subid(j),6) + j - 1;
    end
end

own_packets_ok = own_packets(find( own_packets(:,2) == OK ),:);
own_packets_crc = own_packets(find( own_packets(:,2) == CRC ),:);
own_packets_phy = own_packets(find( own_packets(:,2) == PHY ),:);

foreign_packets = allpackets( find( (allpackets(:,3) == FOREIGN ) & (allpackets(:,2) == OK ) ),:);       %foreignpacket: all packet are ok and foreign

if size(own_packets_ok,1) >= 2
  own_packets_id_diff = own_packets_ok(2:end,6) - own_packets_ok(1:end-1,6);
  own_packets_timediff = own_packets_ok(2:end,1) - own_packets_ok(1:end-1,1);
  packet_interval = own_packets_timediff ./ own_packets_id_diff;

  mean_packet_interval = mean(packet_interval);
  std_packet_interval = std(packet_interval);
else
  mean_packet_interval = interval / 1000;
  std_packet_interval = 0;
end

if ~isempty(own_packets_ok)
    mean_rssi = mean(own_packets_ok(:,7));
    std_rssi = std(own_packets_ok(:,7));
    prctile_rssi = prctile(own_packets_ok(:,7),[ 5 25 50 75 95 ]);
else
    mean_rssi = 0;
    std_rssi =0;
    prctile_rssi = [ 0 0 0 0 0 ];
end

if ~isempty(foreign_packets)
    mean_forrssi = mean(foreign_packets(:,7));
    std_forrssi = std(foreign_packets(:,7));
    prctile_forrssi = prctile(foreign_packets(:,7),[ 5 25 50 75 95 ]);
else
    mean_forrssi = 0;
    std_forrssi = 0;
    prctile_forrssi = [ 0 0 0 0 0 ];
end

if ~isempty(allpackets)
  start_time =allpackets(1,1);
  end_time = allpackets(end,1);

  if ~isempty(own_packets_ok)
    first_packet_id = own_packets_ok(1,6);
    last_packet_id = own_packets_ok(end,6);
    first_packet_time = own_packets_ok(1,1);
    possible_start_id = first_packet_id - floor ( ( first_packet_time - start_time ) /  mean_packet_interval );
    possible_end_id = last_packet_id + floor ( ( end_time - own_packets_ok(end,1) )  / mean_packet_interval );
    possible_first_id_time = first_packet_time - ( ( possible_start_id - first_packet_id ) * mean_packet_interval );

    count_send_packets = possible_end_id - possible_start_id + 1;

    per = 1 - ( size(own_packets_ok,1) / count_send_packets );
  else
    count_send_packets = floor( (end_time - start_time) / mean_packet_interval );
    per = 1;
  end

%divide into bins (time) and calc
  bin_timesize = ( ( end_time - start_time ) / numbins );

  bin_own_per = [];
  bin_own_rssi = [];
  bin_own_packet_count = [];
  bin_for_rssi = [];
  bin_for_medium_time = [];
  bin_for_packet_count = [];
  bin_for_own_rate = [];

  for i=1:numbins

    bin_starttime = start_time + ( ( i - 1 ) * bin_timesize );
    bin_endtime = start_time + ( i * bin_timesize );

    bin_own_packets_ok = own_packets_ok(find(own_packets_ok(:,1) >= bin_starttime & own_packets_ok(:,1) < bin_endtime),:);
    bin_foreign_packets = foreign_packets(find(foreign_packets(:,1) >= bin_starttime & foreign_packets(:,1) < bin_endtime),:);

    if ~isempty(bin_own_packets_ok)
      bin_first_packet_id = bin_own_packets_ok(1,6);
      bin_last_packet_id = bin_own_packets_ok(end,6);
      bin_first_packet_time = bin_own_packets_ok(1,1);
      bin_possible_start_id = bin_first_packet_id - floor ( ( bin_first_packet_time - bin_starttime ) /  mean_packet_interval );
      bin_possible_end_id = bin_last_packet_id + floor ( ( bin_endtime - bin_own_packets_ok(end,1) )  / mean_packet_interval );
      possible_first_id_time = first_packet_time - ( ( possible_start_id - first_packet_id ) * mean_packet_interval );

      bin_own_per_ac = 1 - ( size( bin_own_packets_ok,1) / ( bin_possible_end_id - bin_possible_start_id + 1 ) );
      bin_own_rssi_ac = mean( bin_own_packets_ok(:,7));
      bin_own_packet_count_ac =  size( bin_own_packets_ok,1);
    else
      bin_own_per_ac = 1;
      bin_own_rssi_ac = MIN_RSSI;
      bin_own_packet_count_ac = 0;
    end

    if ~isempty(bin_foreign_packets)
      bin_for_rssi_ac = mean(bin_foreign_packets(:,7));
      bin_for_packet_count_ac = size( bin_foreign_packets,1);

      if ( ~isempty(bin_own_packets_ok) )
        bin_for_own_rate_ac = bin_for_packet_count_ac / bin_own_packet_count_ac;
      else
        bin_for_own_rate_ac = MAX_FOREIGN_RATE;
      end

       bin_for_medium_time_ac = sum(8 * bin_foreign_packets(:,4)  ./ bin_foreign_packets(:,5) / 1e6);
    
    else
       bin_for_rssi_ac = MIN_RSSI;
       bin_for_packet_count_ac = 0;
       bin_for_own_rate_ac = 0;
       bin_for_medium_time_ac = 0;
    end

    bin_own_per = [ bin_own_per bin_own_per_ac ];
    bin_own_rssi = [ bin_own_rssi bin_own_rssi_ac];
    bin_own_packet_count = [ bin_own_packet_count bin_own_packet_count_ac ];

    bin_for_packet_count = [ bin_for_packet_count bin_for_packet_count_ac ];
    bin_for_rssi = [ bin_for_rssi bin_for_rssi_ac];
    bin_for_own_rate = [ bin_for_own_rate bin_for_own_rate_ac ];
    bin_for_medium_time = [ bin_for_medium_time bin_for_medium_time_ac ];
  end

  mean_bin_per = mean(bin_own_per);
  std_bin_per = std(bin_own_per);

  count_ghost_packets=size(find( allpackets(:,3) == GHOST ) , 1 );
  count_for_packets=size(find( allpackets(:,3) == FOREIGN ) , 1 );

end

clear bin_own_per_ac bin_own_rssi_ac bin_for_rssi_ac bin_own_packet_count_ac bin_for_packet_count_ac bin_own_rssi_ac bin_for_own_rate_ac bin_for_medium_time_ac

save(packet_stat_file);

end

