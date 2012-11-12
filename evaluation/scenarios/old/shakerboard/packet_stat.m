function packet_stat(packetfile,numbins,runtime)
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
bitrates=unique(allpackets(:,CHANNEL));

node=1;
device=0;
bitrate=1;
channel=14;
point=1;

own_packets = allpackets( find( ( allpackets(:,FOROWN) == OWN ) & ( allpackets(:,BITRATE) == bitrate )  & ...
                                                  ( allpackets(:,CHANNEL) == channel )  & ( allpackets(:,NODE) == node )  & ...
                                                  ( allpackets(:,DEVICE) == device ) & ( allpackets(:,POINT) == point ) ) ,:);

first_fault_txpower=own_packets(1,TXPOWER);
last_fault_txpower=own_packets(end,TXPOWER);


startpos=min(find(own_packets(:,TXPOWER) != first_fault_txpower ));
endpos=max(find(own_packets(:,TXPOWER) != last_fault_txpower ));

own_packets_correct=own_packets(startpos:endpos,:);

txpower=unique(own_packets_correct(:,TXPOWER));

clearplot;

for i = 1:size(txpower,1)

own_packets=own_packets_correct(find( own_packets_correct(:,TXPOWER) == txpower(i) ),:);

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
    possible_start_id = 0;
    possible_end_id = floor(runtime / mean_packet_interval);

    first_packet_id = own_packets(1,PID);
    last_packet_id = own_packets(end,PID);

    count_send_packets = possible_end_id - possible_start_id + 1;

    per = 1 - ( size(own_packets,1) / count_send_packets ); 
  else
    per = 1;
  end

%divide into bins (time) and calc
  bin_packetsize = ( count_send_packets / numbins );

  bin_own_per = [];
  bin_own_rssi = [];
  bin_own_packet_count = [];
  bin_for_rssi = [];
  bin_for_medium_time = [];
  bin_for_packet_count = [];
  bin_for_own_rate = [];

  for r=1:numbins

    bin_startpacket = floor( ( r - 1 ) * bin_packetsize );
    bin_endpacket = floor( r * bin_packetsize );

    bin_own_packets = own_packets(find(own_packets(:,PID) >= bin_startpacket & own_packets(:,PID) < bin_endpacket),:);

    if ~isempty(bin_own_packets)
      bin_own_per_ac = 1 - ( size( bin_own_packets,1) / ( bin_endpacket - bin_startpacket + 1 ) );
      bin_own_rssi_ac = mean( bin_own_packets (:,RSSI));
      bin_own_packet_count_ac =  size( bin_own_packets,1);
    else
      bin_own_per_ac = 1;
      bin_own_rssi_ac = MIN_RSSI;
      bin_own_packet_count_ac = 0;
    end

    bin_own_per = [ bin_own_per bin_own_per_ac ];
    bin_own_rssi = [ bin_own_rssi bin_own_rssi_ac];
    bin_own_packet_count = [ bin_own_packet_count bin_own_packet_count_ac ];

  end

  %c=colormap;
  scatter( 1:numbins, bin_own_rssi );
  hold on;

  mean_bin_per = mean(bin_own_per);
  std_bin_per = std(bin_own_per);


end

clear bin_own_per_ac bin_own_rssi_ac bin_for_rssi_ac bin_own_packet_count_ac bin_for_packet_count_ac bin_own_rssi_ac bin_for_own_rate_ac bin_for_medium_time_ac


end

