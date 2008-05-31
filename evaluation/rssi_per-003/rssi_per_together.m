function rssi_per_together()

scrsz = [ 1 1 1600 1200 ];
figure('Visible', 'off','Position',[1 scrsz(4) scrsz(3) scrsz(4)])
set(gcf,'paperpositionmode','auto'); 
set(gca,'fontsize',16);
mycolor=colormap(lines(16));

lg={};

index=1;
for filenum=1:15
  sname=strcat( num2str(filenum), '_sender.dat');
  rname=strcat( num2str(filenum), '_receiver.dat');

  s = load(sname);
  r = load(rname);

  MIN_RSSI = -5;
  MAX_FG_RATE = -1;
  if (~isempty(r))

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
    bin_fg_rssi = [];
    
    if (~isempty(time_offset))
	for i=1:numbins
    	    sp = s((i-1)*binsize+1:i*binsize,:);
            startbin = sp(1,1) + time_offset;
	    endbin   = sp(end,1) + time_offset;
            own_recp = own_rec(find(own_rec(:,1) >= startbin & own_rec(:,1) < endbin),:);
	    fg_recp = fg_rec(find(fg_rec(:,1) >= startbin & fg_rec(:,1) < endbin),:);
	    if ( ~isempty(own_recp) )
    	    	fg_rate = size(fg_recp,1) / size(own_recp,1);
	    else
		fg_rate = MAX_FG_RATE;
	    end
    	    
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
    	    if (~isempty(fg_recp))
        	bin_fg_rssi = [bin_fg_rssi mean(fg_recp(:,4))];
    	    else
        	bin_fg_rssi = [bin_fg_rssi MIN_RSSI];
    	    end
	end
    end

  

  mean_per = 1 - size(own_rec,1) / size(s,1);
  mean_own_rssi = mean(own_rec(:,4));
 if ( ~isempty(fg_rec) )
    	mean_fg_rssi = mean(fg_rec(:,4));
    else
	mean_fg_rssi = MIN_RSSI;
    end
  accolor=mycolor(filenum,:);
 % sc=scatter(bin_rssi, bin_per,40, accolor,'filled');
  sc=scatter(bin_rssi, bin_per,40,'filled');
  ylim([0 1]);
  set(sc,'MarkerFaceColor', accolor);
  %alpha(sc,0.5);
  hold on;

  lg{index}=strcat('TXPower\_', num2str(filenum));
  index=index+1;
  
  end

end
  legend(lg,'location','Best');

  title(strcat('TX: ', num2str(size(s,1)), ', Bins: ', num2str(numbins)));
  xlabel('RSSI');
  ylabel('PER');

  print('-dpng', 'rssi_per.png');

end
