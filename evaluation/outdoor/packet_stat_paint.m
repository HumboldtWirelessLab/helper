function rssi_per(packet_stat_file,fname)

  load(packet_stat_file);

  scrsz = [ 1 1 1600 1200 ];
  figure('Visible', 'off','Position',[1 scrsz(4) scrsz(3) scrsz(4)])
  set(gcf,'paperpositionmode','auto');
  set(gca,'fontsize',16);

  subplot(5,1,1);
  scatter(bin_own_rssi, bin_own_per);
  ylim([0 1.0])
  grid on;
  xlabel('RSSI');
  ylabel('PER');
    
  title(strcat('TX: ', num2str(bin_own_packet_count_ac), ', Bins: ', num2str(numbins), ', mean\_per: ', num2str(per),', std\_per: ', num2str(std_bin_per) ,', mean\_own\_rssi: ', num2str(mean_rssi),', std\_rssi: ', num2str(std_rssi) , ', mean\_fg\_rssi: ', num2str(mean_forrssi),', std\_fg\_rssi: ', num2str(std_forrssi)));
    
  subplot(5,1,2);
  scatter(bin_for_packet_count, bin_own_packet_count)
  grid on;
  xlabel('foreign');
  ylabel('own');
    
  subplot(5,1,3);
  scatter(bin_for_own_rate, bin_own_rssi)
  grid on;
  xlabel('foreign/own');
  ylabel('RSSI');
    
  subplot(5,1,4);
  scatter(bin_for_medium_time, bin_own_per)
  ylim([0 1.0])
  grid on;
  xlabel('foreign medium time');
  ylabel('PER');
    
  subplot(5,1,5);
  scatter(bin_own_rssi, bin_for_rssi)
  grid on;
  xlabel('OWN RSSI');
  ylabel('FG RSSI');
    
%exportfig(gcf, strcat(sname, '.eps'),'LineStyleMap',[],'Color','rgb');
  fname = strcat(rname,'.', num2str(psize - 32),'.',num2str(bitrate),'.png');
  print('-dpng', fname);

  clear;

end
