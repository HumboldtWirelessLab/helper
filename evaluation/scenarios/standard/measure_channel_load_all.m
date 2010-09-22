function measure_channel_load_all(nodes)

nodes

try
  chan_load_perc_ok = zeros(size(nodes,2), 4);
catch
  chan_load_perc_ok = [];
end

try
  chan_load_perc_crc = zeros(size(nodes,2), 1);
catch
  chan_load_perc_crc = [];
end

%chan_load_perc_phy = zeros(size(nodes,2), 1);
for i=1:size(nodes,2)
   i
   chan_load_perc_ok(i,:) = measure_channel_load(strcat(nodes{i}, '.dump.ok.dat'), true); 
   chan_load_perc_crc(i,:) = measure_channel_load(strcat(nodes{i}, '.dump.crc.dat'), false); 
   %chan_load_perc_phy(i,:) = measure_channel_load(strcat(nodes{i}, '.dump.phy.dat')); 
end


scrsz = [ 1 1 1600 1200];
%get(0,'ScreenSize');
figure('Position',[100 scrsz(4)/2-100 scrsz(3)/1.5 scrsz(4)/2]);
colormap summer;
chan_load_perc = [chan_load_perc_ok(:,1) chan_load_perc_crc];
bar(chan_load_perc, 'stack');
set(gca,'XTick',1:size(nodes,2));
set(gca,'XTickLabel', nodes);
legend('OK', 'CRC');
ylabel('Channel Load (%)');
xlabel('Node');
title('Frames with status OK or CRC');
grid on;
exportfig(gcf, 'measure_channel_load_all_frame_stat.eps','LineStyleMap',[],'Color','rgb');

figure('Position',[100 scrsz(4)/2-100 scrsz(3)/1.5 scrsz(4)/2]);
colormap summer;
bar(chan_load_perc_ok(:,2:end), 'stack');
set(gca,'XTick',1:size(nodes,2));
set(gca,'XTickLabel', nodes);
legend('MGMT', 'CNTL', 'DATA');
ylabel('Channel Load (%)');
xlabel('Node');
title('Successful frames only');
grid on;
exportfig(gcf, 'measure_channel_load_all_frame_type.eps','LineStyleMap',[],'Color','rgb');

load('all_bssid.dat');
figure('Position',[100 scrsz(4)/2-100 scrsz(3)/1.5 scrsz(4)/2]);
colormap summer;
bar(all_bssid);
set(gca,'XTick',1:size(nodes,2));
set(gca,'XTickLabel', nodes);
ylabel('Number');
xlabel('Node');
title('Identified BSSets from Beacons + Probe Response');
grid on;
exportfig(gcf, 'measure_channel_load_all_bss_iden.eps','LineStyleMap',[],'Color','rgb');

end