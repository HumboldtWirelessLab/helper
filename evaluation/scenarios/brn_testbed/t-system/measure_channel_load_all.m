function measure_channel_load_all(nodes)

%clear;
%addpath('3/');

%nodes = {'wgt25' 'wgt28' 'wgt31' 'wgt32' 'wgt33' 'wgt44' 'wgt46' 'wgt49' 'wgt63' 'wgt70' 'wgt74' 'wgt76' 'wgt77' 'wgt78' 'wgt79' 'wgt81' 'wgt82'};
%nodes = {'wgt25' 'wgt28' 'wgt31' 'wgt33' 'wgt44' 'wgt46' 'wgt49' 'wgt63' 'wgt70' 'wgt74' 'wgt76' 'wgt77' 'wgt78' 'wgt79' 'wgt81' 'wgt82'};
%nodes = {'wgt25' 'wgt29' 'wgt31' 'wgt32' 'wgt33' 'wgt37' 'wgt41' 'wgt44' 'wgt45' 'wgt46' 'wgt49' 'wgt63' 'wgt70' 'wgt74' 'wgt76' 'wgt77' 'wgt78' 'wgt79' 'wgt81' 'wgt82' 'sk111' 'sk112' 'sk113' 'sk114'};
%nodes = {'sk110' 'sk111' 'sk112' 'sk113' 'sk114' 'sk115' 'wgt25' 'wgt29' 'wgt31' 'wgt32' 'wgt33' 'wgt37' 'wgt41' 'wgt42' 'wgt44' 'wgt45' 'wgt46' 'wgt49' 'wgt63' 'wgt70' 'wgt74' 'wgt76' 'wgt77' 'wgt78' 'wgt79' 'wgt81' 'wgt82'};
%nodes = {'sk110' 'sk111' 'sk112' 'sk113' 'sk114' 'sk115' 'wgt25' 'wgt31' 'wgt33' 'wgt37' 'wgt41' 'wgt42' 'wgt44' 'wgt45' 'wgt46' 'wgt49' 'wgt63' 'wgt70' 'wgt76' 'wgt77' 'wgt78' 'wgt79' 'wgt81' 'wgt82'};

%nodes=load('nodes.dat')

nodes

chan_load_perc_ok = zeros(size(nodes,2), 4);
chan_load_perc_crc = zeros(size(nodes,2), 1);
%chan_load_perc_phy = zeros(size(nodes,2), 1);
for i=1:size(nodes,2)
   i
   chan_load_perc_ok(i,:) = measure_channel_load(strcat(nodes{i}, '_ok.dat'), true); 
   chan_load_perc_crc(i,:) = measure_channel_load(strcat(nodes{i}, '_crc.dat'), false); 
   %chan_load_perc_phy(i,:) = measure_channel_load(strcat(nodes{i}, '_phy.dat')); 
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