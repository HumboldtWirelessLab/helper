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

  FLOW_ID=13

  %TODO: check: mean over mean? 
  search_params = [ SRC_NODE DST_NODE PKT_SIZE FLOW_ID];
  params=unique(data(:,search_params),'rows');

  res = zeros(size(params,1),size(search_params,2) + 10);
  %size(res)
  cnt=1;
  %res=[];

  for i = 1:size(params,1)
    p = params(i,:);
    %data(:,search_params)
    %ismember(data(:,search_params),p,'rows')

    d = data(ismember(data(:,search_params),p,'rows'),:);
    avg_time = mean(d(:,AVG_TIME));
    min_time = min(d(:,MIN_TIME));
    max_time = max(d(:,MAX_TIME));
    avg_hops = mean(d(:,AVG_HOPS));
    min_hops = min(d(:,MIN_HOPS))
    max_hops = max(d(:,MAX_HOPS));
    avg_rx_pkt = mean(d(:,RX_PKT_COUNT));
    tx_pkt = mean(d(:,TX_PKT_COUNT));
    reach = 100 * (avg_rx_pkt / tx_pkt);
    avg_time_per_hop = mean(d(:,AVG_TIME)./d(:,AVG_HOPS));

    %res = [ res ; p avg_time min_time max_time avg_hops min_hops max_hops avg_rx_pkt avg_rx_pkt  tx_pkt reach ];
    %size([p avg_time min_time max_time avg_hops min_hops max_hops avg_rx_pkt tx_pkt reach avg_time_per_hop])

    res(cnt,:)=[p avg_time min_time max_time avg_hops min_hops max_hops avg_rx_pkt tx_pkt reach avg_time_per_hop];
    cnt=cnt+1;
  end

  %res
  %disp(res);
  csvwrite(of,res);

end