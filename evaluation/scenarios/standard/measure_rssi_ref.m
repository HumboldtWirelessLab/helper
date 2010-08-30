function measure_rssi_ref(nodes)
%clear;
%addpath('3/');

%nodes = {'wgt25' 'wgt28' 'wgt31' 'wgt32' 'wgt33' 'wgt44' 'wgt46' 'wgt49' 'wgt63' 'wgt70' 'wgt74' 'wgt76' 'wgt77' 'wgt78' 'wgt79' 'wgt81' 'wgt82'};
%nodes = {'wgt25' 'wgt28' 'wgt31' 'wgt33' 'wgt44' 'wgt46' 'wgt49' 'wgt63' 'wgt70' 'wgt74' 'wgt76' 'wgt77' 'wgt78' 'wgt79' 'wgt81' 'wgt82'};
%nodes = {'wgt25' 'wgt29' 'wgt31' 'wgt32' 'wgt33' 'wgt37' 'wgt41' 'wgt44' 'wgt45' 'wgt46' 'wgt49' 'wgt63' 'wgt70' 'wgt74' 'wgt76' 'wgt77' 'wgt78' 'wgt79' 'wgt81' 'wgt82' 'sk111' 'sk112' 'sk113' 'sk114'};
%nodes = {'sk110' 'sk111' 'sk112' 'sk113' 'sk114' 'sk115' 'wgt25' 'wgt29' 'wgt31' 'wgt33' 'wgt37' 'wgt41' 'wgt42' 'wgt44' 'wgt45' 'wgt46' 'wgt49' 'wgt63' 'wgt70' 'wgt74' 'wgt76' 'wgt77' 'wgt78' 'wgt79' 'wgt81' 'wgt82'};

all_rssi = zeros(size(nodes,2), 1);
for i=1:size(nodes,2)
   v = load(strcat(nodes{i}, '_rssi_ref.dat'));
   all_rssi(i) = mean(v);
end

scrsz = [ 1 1 1600 1200];
%scrsz = get(0,'ScreenSize');
figure('Position',[100 scrsz(4)/2-100 scrsz(3)/2 scrsz(4)/2]);
colormap summer;
bar(all_rssi);
set(gca,'XTick',1:size(nodes,2));
set(gca,'XTickLabel', nodes);
ylabel('Mean RSSI');
xlabel('Node');
title('RX Signal Power of Reference Signal');
grid on;

exportfig(gcf, 'measure_rssi_ref.eps','LineStyleMap',[],'Color','rgb');
end
