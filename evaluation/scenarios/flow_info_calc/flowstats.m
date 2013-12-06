function flowstats(f,of)
  data = load(f,'-ASCII');

  RX_NODE=1;
  SRC_NODE=2;
  DST_NODE=3; %dst can be different to RX, e.g. broadcast
  RX_PKT_COUNT=5;
  TX_PKT_COUNT=6;
  PKT_SIZE=7;

  AVG_HOPS=4;
  MIN_HOPS=8;
  MAX_HOPS=9;
  
  AVG_TIME=10;
  MIN_TIME=11;
  MAX_TIME=12;
  
  
  
  
  %TODO: check: mean over mean? 
  search_params = [ SRC_NODE DST_NODE TX_PKT_COUNT PKT_SIZE];
  params=unique(data(:,search_params),'rows')
  
  res = [];
  
  for i = 1:size(params,1)
    p = params(i,:);
    d = data(strmatch(p,data(:,search_params)),:);
    avg_time = mean(d(:,AVG_TIME));
    min_time = min(d(:,MIN_TIME));
    max_time = max(d(:,MAX_TIME));
    avg_hops = mean(d(:,AVG_HOPS));
    min_hops = min(d(:,MIN_HOPS));
    max_hops = max(d(:,MAX_HOPS));
    avg_rx_pkt = mean(d(:,RX_PKT_COUNT));
    tx_pkt = mean(d(:,TX_PKT_COUNT));
    reach = 100 * (avg_rx_pkt / tx_pkt);
    res = [ res ; p avg_time min_time max_time avg_hops min_hops max_hops avg_rx_pkt avg_rx_pkt  tx_pkt reach ];
  end
  
  res
  csvwrite(of,res);
	
end