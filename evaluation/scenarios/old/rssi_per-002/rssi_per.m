function rssi_per(sname, rname)
%s = load('sender_10.dat');
%r = load('receiver_10.dat');

%scrsz = get(0,'ScreenSize');
scrsz = [ 1 1 1600 1200 ];
figure('Visible', 'off','Position',[10 scrsz(4)/4 scrsz(3)/2 scrsz(4)/2])

s = load(sname);
r = load(rname);

MIN_RSSI = -5;

own_rec = r(find(r(:,6) == 1),:);
fg_rec = r(find(r(:,6) == 0),:);
first_packet_id = s(1,7);

time_offset = [];

for i=1:size(s,1)
    first_packet_id = s(i,7);
    time_offset = own_rec(find(own_rec(:,7) == first_packet_id),1) - s(i,1);
    if (~isempty(time_offset))
       break; 
    end
end

numbins = 100;
binsize = ceil(size(s,1) / numbins) - 1;

bin_rssi = [];
bin_per = [];
bin_fg_own_rate = [];
bin_fg = [];
bin_own = [];
bin_fg_med_time = [];

if (~isempty(time_offset))
    for i=1:numbins
       sp = s((i-1)*binsize+1:i*binsize,:);
       startbin = sp(1,1) + time_offset;
       endbin   = sp(end,1) + time_offset;
       own_recp = own_rec(find(own_rec(:,1) >= startbin & own_rec(:,1) < endbin),:);
       fg_recp = fg_rec(find(fg_rec(:,1) >= startbin & fg_rec(:,1) < endbin),:);
       fg_rate = size(fg_recp,1) / size(own_recp,1);
       
       bin_fg_own_rate = [bin_fg_own_rate fg_rate];
       bin_fg = [bin_fg size(fg_recp,1)];
       bin_own = [bin_own size(own_recp,1)];

       fg_medium_time = sum(8 * fg_recp(:,2)  ./ fg_recp(:,3) / 1e6); % s
       bin_fg_med_time = [bin_fg_med_time fg_medium_time];

       per = 1 - size(own_recp,1) / size(sp,1);
       bin_per = [bin_per per];
       if (~isempty(own_recp))
           bin_rssi = [bin_rssi mean(own_recp(:,4))];
       else
           bin_rssi = [bin_rssi MIN_RSSI];
       end
    end
end

subplot(4,1,1);
scatter(bin_rssi, bin_per);
xlabel('RSSI');
ylabel('PER');

subplot(4,1,2);
scatter(bin_fg, bin_own)
xlabel('foreign');
ylabel('own');

subplot(4,1,3);
scatter(bin_fg_own_rate, bin_rssi)
xlabel('foreign/own');
ylabel('RSSI');

subplot(4,1,4);
scatter(bin_fg_med_time, bin_per)
xlabel('foreign medium time');
ylabel('PER');

%exportfig(gcf, strcat(sname, '.eps'),'LineStyleMap',[],'Color','rgb');
fname = strcat(sname, '.png');
print('-dpng', fname);
