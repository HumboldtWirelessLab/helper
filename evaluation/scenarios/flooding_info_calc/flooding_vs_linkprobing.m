function flooding_vs_linkprobing( floodfilename, bcastfilename, basedir, params )

  TX_NODE=1;
  RX_NODE=2;
  TX_OF_RX_CNT=3;
  RX_CNT=4;
  
  floodrawdata=load(floodfilename,'-ASCII');
  bcastdata=load(bcastfilename,'-ASCII');

  tx_cnt_vec = zeros(size(bcastdata,1),1);
  rx_cnt_mat = zeros(size(bcastdata,1),size(bcastdata,2));
  
  flooddata = zeros(size(bcastdata,1),size(bcastdata,2));
  tx_info = unique(floodrawdata(:,[RX_NODE TX_OF_RX_CNT]),'rows');
  %size(tx_info)
  
  for a = 1:size(bcastdata,1)
      cur_tx_info = tx_info(tx_info(:,1) == a,:);
      
      rx_cnt_vec = zeros(size(bcastdata,1),1);

      if ~isempty(cur_tx_info)   %the node sent something? yes,...
            
          tx_cnt = cur_tx_info(2);
          tx_cnt_vec(a) = tx_cnt;
          
          rx_info = floodrawdata(floodrawdata(:,TX_NODE) == a,:);
       
          if ~isempty(rx_info) %it was received by at least one node ? yes,...
              
              for b = 1:size(rx_info,1)
                   rx_node = rx_info(b,RX_NODE);
                   rx_cnt = rx_info(b,RX_CNT);
                   rx_cnt_vec(rx_node) = rx_cnt;
                   rx_cnt_mat(a,rx_node) = 100*rx_cnt/tx_cnt;
              end
          end
              
      else
          tx_cnt = 1;
      end      
      
      flooddata(a,:) = 100*(rx_cnt_vec/tx_cnt);
  end
  
  %tx_cnt_vec
  tx_cnt_mat = repmat(tx_cnt_vec,1,size(bcastdata,1))
  %rx_cnt_mat

  flooddata
  %bcastdata
  %bcastdata(:)
  
  compare_vec = [ bcastdata(:)'; flooddata(:)'; tx_cnt_mat(:)']'
  
  compare_vec = compare_vec((compare_vec(:,1) > 0) & (compare_vec(:,2) > 0),:);
  
  compare_limit = max(tx_cnt_mat(:)) * 0.5;
  
  redcompare = compare_vec((compare_vec(:,3) <= compare_limit),:);
  bluecompare = compare_vec((compare_vec(:,3) > compare_limit),:);

  h1 = figure;
  
  scatter(redcompare(:,1),redcompare(:,2),'r');
  hold on;
  scatter(bluecompare(:,1),bluecompare(:,2),'b');

  xlabel('Linkprobing');
  ylabel('Flooding');
  title('PDR Flooding vs. Linkprobing');
  line([0 100],[0 100],'Color',[0 0 0])

  %print(strcat(basedir,'flooding_vs_linkprobing_',params ,'.png'),'-dpng');
  %saveas(h1, strcat(basedir,'flooding_vs_linkprobing_',params ,'.png'),'png');
  saveas(h1, strcat(basedir,'flooding_vs_linkprobing_',params ,'.eps'),'epsc');
  
  lp_bc_diff = flooddata - bcastdata;
  csvwrite(strcat(basedir,'flooding_vs_linkprobing_diff_',params,'.csv'),lp_bc_diff);

end

