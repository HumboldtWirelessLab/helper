function packet_stat(packetfile,numbins,node,device,bitrate,channel,point)
% psize - Packetsize
% bitrate - Bitrate of own packets

POINT=1;NODE=2;DEVICE=3;TIMESTAMP=4;SIZE=5;BITRATE=6;RSSI=7;SEQ=8;
FOROWN=9;PID=10;INTERVAL=11;CHANNEL=12;SENDBITRATE=13;TXPOWER=14;

FOREIGN=0;
OWN=1;

MIN_RSSI=0;

allpackets=load(packetfile);

allpackets( find( allpackets(:,RSSI) > 100 ),RSSI) = 0;                                                                  % remove wrong rssi

channels=unique(allpackets(:,CHANNEL));
bitrates=unique(allpackets(:,BITRATE));

%node=1;
%device=0;
%bitrate=1;
%channel=14;
%point=1;

own_packets = allpackets( find( ( allpackets(:,FOROWN) == OWN ) & ( allpackets(:,BITRATE) == bitrate )  & ...
                                                  ( allpackets(:,CHANNEL) == channel )  & ( allpackets(:,NODE) == node )  & ...
                                                  ( allpackets(:,DEVICE) == device ) & ( allpackets(:,POINT) == point ) ) ,:);

  if ~isempty(own_packets)
    if size(own_packets,1) >= 2
      own_packets_id_diff = own_packets(2:end,PID) - own_packets(1:end-1,PID);
      own_packets_timediff = own_packets(2:end,TIMESTAMP) - own_packets(1:end-1,TIMESTAMP);
      packet_interval = own_packets_timediff ./ own_packets_id_diff;

      mean_packet_interval = mean(packet_interval)
      std_packet_interval = std(packet_interval)
    else
      mean_packet_interval =  own_packets(1,TIMESTAMP) / 1000;
      std_packet_interval = 0;
    end
  end

  if ~isempty(own_packets)
    mean_rssi = mean(own_packets(:,RSSI));
    std_rssi = std(own_packets(:,RSSI));
    prctile_rssi = prctile(own_packets(:,RSSI),[ 5 25 50 75 95 ]);
  else
    mean_rssi = 0;
    std_rssi =0;
    prctile_rssi = [ 0 0 0 0 0 ];
  end


  if ~isempty(own_packets)
    first_packet_id = own_packets(1,PID);
    last_packet_id = own_packets(end,PID);

    count_send_packets = last_packet_id - first_packet_id + 1;

    per = 1 - ( size(own_packets,1) / count_send_packets ); 
  else
    per = 1;
  end

%divide into bins (time) and calc
  bin_packetsize = ( count_send_packets / numbins );

  bin_own_per = [];
  bin_own_rssi = [];
  bin_own_packet_count = [];
  bin_own_int_std = [];
  bin_own_int_mean = [];

  for r=1:numbins

    bin_startpacket = floor( ( r - 1 ) * bin_packetsize );
    bin_endpacket = floor( r * bin_packetsize );

    bin_own_packets = own_packets(find(own_packets(:,PID) >= bin_startpacket & own_packets(:,PID) < bin_endpacket),:);

    if ~isempty(bin_own_packets)
      bin_own_per_ac = 1 - ( size( bin_own_packets,1) / ( bin_endpacket - bin_startpacket + 1 ) );
      bin_own_rssi_ac = mean( bin_own_packets (:,RSSI));
      bin_own_packet_count_ac =  size( bin_own_packets,1);

      if size(bin_own_packets,1) >= 3
        bin_own_packets_id_diff = bin_own_packets(2:end,PID) - bin_own_packets(1:end-1,PID);
        bin_own_packets_timediff = bin_own_packets(2:end,TIMESTAMP) - bin_own_packets(1:end-1,TIMESTAMP);
        bin_packet_interval = bin_own_packets_timediff ./ bin_own_packets_id_diff;

        bin_own_int_mean_ac = mean(bin_packet_interval)
        bin_own_int_std_acl = std(bin_packet_interval)
      else
        bin_own_int_mean_ac=mean_packet_interval;
        bin_own_int_std_ac=std_packet_interval;
      end

    else
      bin_own_per_ac = 1;
      bin_own_rssi_ac = MIN_RSSI;
      bin_own_packet_count_ac = 0;
      bin_own_int_mean_ac=mean_packet_interval;
      bin_own_int_std_ac=std_packet_interval;
    end

    bin_own_per = [ bin_own_per bin_own_per_ac ];
    bin_own_rssi = [ bin_own_rssi bin_own_rssi_ac];
    bin_own_packet_count = [ bin_own_packet_count bin_own_packet_count_ac ];
    bin_own_int_mean = [ bin_own_int_mean bin_own_int_mean_ac ];    
    bin_own_int_std = [ bin_own_int_std bin_own_int_std_ac ];    

  end

  %c=colormap;
  subplot(4,1,1);
  scatter( 1:numbins, bin_own_rssi );
  subplot(4,1,2);
  scatter( 1:numbins, bin_own_per );
  subplot(4,1,3);
  scatter( 1:numbins, bin_own_int_mean );
  subplot(4,1,4);
  scatter( 1:numbins, bin_own_int_std );

  mean_bin_per = mean(bin_own_per);
  std_bin_per = std(bin_own_per);

end

clear bin_own_per_ac bin_own_rssi_ac bin_for_rssi_ac bin_own_packet_count_ac bin_for_packet_count_ac bin_own_rssi_ac bin_for_own_rate_ac bin_for_medium_time_ac


end

