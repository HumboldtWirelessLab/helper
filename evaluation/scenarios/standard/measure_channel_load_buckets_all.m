function measure_channel_load_buckets_all(nodes)

detailed = false;
scrsz = [ 1 1 1600 1200];

nodes

no_buckets = 1000;%100;
all_data = zeros(no_buckets, size(nodes,2));

for i=1:size(nodes,2)
   i
   chan_load_perc_ok = measure_channel_load_buckets(strcat(nodes{i}, '_ok.dat'), true, no_buckets); 
   chan_load_perc_crc = measure_channel_load_buckets(strcat(nodes{i}, '_crc.dat'), false, no_buckets); 
   %chan_load_perc_phy(i,:) = measure_channel_load(strcat(nodes{i}, '_phy.dat')); 
   
   data = [chan_load_perc_ok(:,2:end) chan_load_perc_crc(:,1)];
   all_data(:,i) = chan_load_perc_ok(:,1);
   if (detailed || i==1)
    figure('Position',[100 scrsz(4)/2-100 scrsz(3)/2 scrsz(4)/2]);
    colormap Jet;
    area(data);
    legend('MGMT', 'CNTL', 'DATA', 'CRC');
    ylabel('Channel Load (%)');
    xlabel('Bucket ID');
    title(nodes{i});
    grid on;
   end
end

figure('Position',[100 scrsz(4)/2-100 scrsz(3)/2 scrsz(4)/2]);
h = surf(all_data);
colorbar;
set(h, 'EdgeColor', 'None');
%xlabel('Space (node ID)');
xlabel('Channel (1-13)');
ylabel('Time');
zlabel('Channel Load (%)');
title('Only Successful Packets');
exportfig(gcf, 'measure_channel_load_buckets_all.eps','LineStyleMap',[],'Color','rgb');

end
