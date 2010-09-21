function measure_rssi_ref(nodes)

all_rssi = zeros(size(nodes,2), 1);
for i=1:size(nodes,2)
   v = load(strcat(nodes{i}, '.dump.rssi_ref.dat'));
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
