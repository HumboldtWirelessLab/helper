function rssi_per(rname,psize,bitrate,interval)

scrsz = [ 1 1 1600 1200 ];
figure('Visible', 'off','Position',[1 scrsz(4) scrsz(3) scrsz(4)])
set(gcf,'paperpositionmode','auto');
set(gca,'fontsize',16);

r = load(rname);

MIN_RSSI = -5;
MAX_FG_RATE = -1;

if (~isempty(r))
    r( find( r(:,7) > 60 ),7) = 0;

    r( find( r(:,4) ~= psize ),3) = 0;   %all foreign, which don't match to the given Packetsize
    r( find( r(:,5) ~= bitrate ),3) = 0; %all foreign, which don't match to the given Bitrate
    r( find( r(:,2) ~= 0 ),3) = 0;       %all foreign, which are not correct
	
    own_rec = r( find( r(:,3) == 1 ),:);
    own_rec_ok = own_rec(find( own_rec(:,2) == 0 ),:);
    fg_rec = r(find(r(:,3) == 0),:);
 
if (~isempty(own_rec))

    first_packet_id = own_rec_ok(1,6);
    last_packet_id = own_rec_ok(end,6);
    first_packet_time = own_rec_ok(1,1);
    start_time = r(1,1);
    end_time = r(end,1);
    possible_start_id = first_packet_id - floor ( ( ( first_packet_time - start_time) * 1000 ) / interval );
    possible_end_id = last_packet_id + floor ( ( ( end_time - own_rec_ok(end,1) ) * 1000 ) / interval );
    possible_first_id_time = first_packet_time - ( ( ( possible_start_id - first_packet_id ) * interval ) / 1000 );
    packet_num =   possible_end_id - possible_start_id + 1;

    numbins = 100;
    binsize = ceil( packet_num / numbins ) - 1;

    bin_rssi = [];
    bin_per = [];
    bin_fg_own_rate = [];
    bin_fg = [];
    bin_own = [];
    bin_fg_med_time = [];
    bin_fg_rssi = [];
    
    for i=1:numbins
        startbin = ( ( ( ( i-1 ) * binsize ) * interval ) / 1000 ) + possible_first_id_time;
	endbin = ( ( ( ( i * binsize ) - 1 ) * interval ) / 1000 ) + possible_first_id_time;

        own_recp = own_rec_ok(find(own_rec_ok(:,1) >= startbin & own_rec_ok(:,1) < endbin),:);
        fg_recp = fg_rec(find(fg_rec(:,1) >= startbin & fg_rec(:,1) < endbin),:);

        if ( ~isempty(own_recp) )
    	    fg_rate = size(fg_recp,1) / size(own_recp,1);
	else
	    fg_rate = MAX_FG_RATE;
	end

	bin_fg_own_rate = [bin_fg_own_rate fg_rate];
    	bin_fg = [bin_fg size(fg_recp,1)];
        bin_own = [bin_own size(own_recp,1)];
	    
        %				Packetsize     Bitrate
    	fg_medium_time = sum(8 * fg_recp(:,4)  ./ fg_recp(:,5) / 1e6); % s
   	bin_fg_med_time = [bin_fg_med_time fg_medium_time];
    
    	per = 1 - size(own_recp,1) / binsize;
   	bin_per = [bin_per per];

    	if (~isempty(own_recp))
	       	bin_rssi = [bin_rssi mean(own_recp(:,7))];
    	else
	       	bin_rssi = [bin_rssi MIN_RSSI];
  	end

	if (~isempty(fg_recp))
        	bin_fg_rssi = [bin_fg_rssi mean(fg_recp(:,7))];
    	else
        	bin_fg_rssi = [bin_fg_rssi MIN_RSSI];
    	end
    end

    subplot(5,1,1);
    scatter(bin_rssi, bin_per);
    ylim([0 1.0])
    grid on;
    xlabel('RSSI');
    ylabel('PER');
    
    mean_per = 1 - size(own_rec_ok,1) / packet_num;
    mean_own_rssi = mean(own_rec_ok(:,7));
    if ( ~isempty(fg_rec) )
    	mean_fg_rssi = mean(fg_rec(:,7));
    else
	mean_fg_rssi = MIN_RSSI;
    end
    
    title(strcat('TX: ', num2str(packet_num), ', Bins: ', num2str(numbins), ', mean\_per: ', num2str(mean_per),', std\_per: ', num2str(std(bin_per)) ,', mean\_own\_rssi: ', num2str(mean_own_rssi),', std\_rssi: ', num2str(std(own_rec_ok(:,7))) , ', mean\_fg\_rssi: ', num2str(mean_fg_rssi)));
    
    subplot(5,1,2);
    scatter(bin_fg, bin_own)
    grid on;
    xlabel('foreign');
    ylabel('own');
    
    subplot(5,1,3);
    scatter(bin_fg_own_rate, bin_rssi)
    grid on;
    xlabel('foreign/own');
    ylabel('RSSI');
    
    subplot(5,1,4);
    scatter(bin_fg_med_time, bin_per)
    ylim([0 1.0])
    grid on;
    xlabel('foreign medium time');
    ylabel('PER');
    
    subplot(5,1,5);
    scatter(bin_rssi, bin_fg_rssi)
    grid on;
    xlabel('OWN RSSI');
    ylabel('FG RSSI');
    
%    %exportfig(gcf, strcat(sname, '.eps'),'LineStyleMap',[],'Color','rgb');
    fname = strcat(rname,'.', num2str(psize - 32),'.',num2str(bitrate),'.png');
    print('-dpng', fname);
end
end
end
