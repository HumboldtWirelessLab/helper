function flooding_vs_linkprobing( floodfilename, floodpktfile, bcastfilename, basedir, params )

  flooddata=load(floodfilename,'-ASCII');
  floodpktdata=load(floodpktfile,'-ASCII');
  bcastdata=load(bcastfilename,'-ASCII');

  lp_bc_diff=bcastdata-flooddata;

  flooddata=reshape(flooddata,size(flooddata,1)*size(flooddata,1),1);
  floodpktdata=reshape(floodpktdata,size(floodpktdata,1)*size(floodpktdata,1),1);
  bcastdata=reshape(bcastdata,size(bcastdata,1)*size(bcastdata,1),1);

  max_flood_pkts=max(floodpktdata);
  flood_frac_pkt=floodpktdata/max_flood_pkts;

  size(flooddata)
  size(bcastdata)


  redflood=flooddata(find(flood_frac_pkt(:,:) <= 0.5));
  redbcast=bcastdata(find(flood_frac_pkt(:,:) <= 0.5));

  blueflood=flooddata(find(flood_frac_pkt(:,:) > 0.5));
  bluebcast=bcastdata(find(flood_frac_pkt(:,:) > 0.5));

  scatter(redflood,redbcast,'r');
  hold on;
  scatter(blueflood,bluebcast,'b');

  xlabel('Flooding');
  ylabel('Linkprobing');
  title('PDR Flooding vs. Linkprobing');

  csvwrite(strcat(basedir,'flooding_vs_linkprobing_diff_',params,'.csv'),lp_bc_diff);
  
  %print(strcat(basedir,'flooding_vs_linkprobing_',params ,'.png'),'-dpng');
  saveas(h1, strcat(basedir,'flooding_vs_linkprobing_',params ,'.png'),'png');
  saveas(h1, strcat(basedir,'flooding_vs_linkprobing_',params ,'.eps'),'epsc');

  lp_bc_diff=reshape(lp_bc_diff,size(lp_bc_diff,1)*size(lp_bc_diff,1),1);

end

