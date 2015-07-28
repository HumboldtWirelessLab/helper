function flooding2pdr( filename, basedir )
%filename = 'floodingforwardstats.mat';
%basedir = './';

%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

LASTNODE=1;
NODE=2;
SRCNODE=3;
%PKTSIZE=4;
PKTCNT=10;

ID=11;
%FWD_CNT=12;
SENT_CNT=13;
FORWARDED=14;
RESPONSIBLE=15;

RCV_CNT=18;

data=load(filename,'-ASCII');

src_nodes=unique(data(:,SRCNODE)); 
allnodes=unique(data(:,NODE));

max_nodes= max(allnodes);
  
for i = 1:size(src_nodes,1)
     src_node=src_nodes(i);

     %final data
     pdr_lasthop_mat=zeros(max_nodes,max_nodes);         %pdr last hop -> node

     pdr_mat=zeros(max_nodes,1);                         %overall pdr (src to node)
     
     rx_pkt_cnt_mat=zeros(max_nodes,max_nodes);          %rx packet from lastnode to node
     tx_pkt_cnt=zeros(max_nodes,1);                      %tx packets of lastnode
     
     fwded_pkt_cnt_mat=zeros(max_nodes,max_nodes);       %fwded packet of node of lastnode

     response_cnt_mat=zeros(max_nodes,max_nodes);        %fwded packet of node of lastnode
     
     %preselection
     src_data=data(data(:,SRCNODE)==src_node,:);         %quellknoten
     data_s=src_data(src_data(:,SENT_CNT) > 0,:);        %infos zu sent
     data_r=src_data(src_data(:,RCV_CNT) > 0,:);         %infos zu rx
     %data_f=src_data(src_data(:,FWD_CNT) > 0,:);        %infos zu fwd
     data_fwd=src_data(src_data(:,FORWARDED) > 0,:);     %packet of last node was forwarded (first p)
     data_resp=src_data(src_data(:,RESPONSIBLE) == 1,:); %Info includes info about resposility
        
     packets=max(src_data(:,PKTCNT));                    %pkt ids
     packet_count=packets;

     for a = 1:size(allnodes,1)                          %last
         lastnode=allnodes(a);

         %infos that other nodes know about the last node                
         all_rx_of_lastnode=data_r(data_r(:,LASTNODE)==lastnode,:);
         all_has_fwded_of_lastnode=data_fwd(data_fwd(:,LASTNODE)==lastnode,:);

         %infos about the lastnode (by node itself)
         all_tx_of_lastnode=data_s(data_s(:,NODE)==lastnode,:);
         %all_fwd_of_lastnode=data_f(data_f(:,NODE)==lastnode,:);

         all_rx_packets=data_r(data_r(:,NODE)==lastnode,:);

          %some infos
         lastnode_pkt_count_sent=unique(all_tx_of_lastnode(:,[ID SENT_CNT]),'rows');
         %sum(lastnode_pkt_count_sent(:,2))
         
         %lastnode_pkt_count_fwd=unique(all_fwd_of_lastnode(:,[ID FWD_CNT]),'rows');
         %count_sents_of_lastnode=sum(lastnode_pkt_count_fwd(:,2))

         all_rx_packets_count=size(unique(all_rx_packets(:,ID)),1);
         pdr_mat(lastnode) = all_rx_packets_count/packet_count;

         tx_pkt_cnt(lastnode)=sum(lastnode_pkt_count_sent(:,2));
         
         all_src_resp_info=data_resp(data_resp(:,NODE)==lastnode,:);
         
         for b = 1:size(allnodes,1)         %dst
             
            node = allnodes(b);
            
            if ( node == lastnode )
                continue;
            end
          
            rx_packets=unique(all_rx_of_lastnode(all_rx_of_lastnode(:,NODE)==node,[ID RCV_CNT]),'rows');  %recv p which are sent by lasthop
            rx_packets_count=sum(rx_packets(:,2));
            
            fwds_of_lastnode = all_has_fwded_of_lastnode((all_has_fwded_of_lastnode(:,NODE)==node),ID);

            all_dst_resp_info=all_src_resp_info(all_src_resp_info(:,LASTNODE)==node,:);

            if isempty(rx_packets)
                lasthop_tx_pdr=0;
            else

                if isempty(lastnode_pkt_count_sent)
                    lasthop_tx_pdr=0;
                else
                    lasthop_tx_pdr=rx_packets_count/sum(lastnode_pkt_count_sent(:,2));
                end
            end

            rx_pkt_cnt_mat(lastnode,node)          = rx_packets_count;
            pdr_lasthop_mat(lastnode,node)         = lasthop_tx_pdr;
            fwded_pkt_cnt_mat(lastnode,node)       = size(fwds_of_lastnode,1);
            response_cnt_mat(node,lastnode)        = size(all_dst_resp_info,1);
         end
     end
     
    pdr_mat = 100*pdr_mat;
    pdr_lasthop_mat = 100*pdr_lasthop_mat;

    tests = 1;
		
	%tests
    if ( tests == 1 )
	  fwded_pkt_cnt_mat_colsum=sum(fwded_pkt_cnt_mat,1)/packet_count;
	  if ( (max(fwded_pkt_cnt_mat_colsum) > 1) || (min(fwded_pkt_cnt_mat_colsum) < 0) )
	    disp('Error fwded packets');
	  end
    end

    non_zero_fwd = find(fwded_pkt_cnt_mat ~= 0);
    
    fwd_links = [ mod((non_zero_fwd-1),max_nodes)+1 floor((non_zero_fwd-1)/max_nodes)+1 fwded_pkt_cnt_mat(non_zero_fwd) ];
    

    csvwrite(strcat(basedir,'flooding_src_pdr', '','.csv'),pdr_mat);
    dlmwrite(strcat(basedir, 'flooding_src_pdr.mat'), pdr_mat, ' ')

    csvwrite(strcat(basedir,'flooding_lasthop_pdr', '','.csv'),pdr_lasthop_mat);
    dlmwrite(strcat(basedir, 'flooding_lasthop_pdr.mat'), pdr_lasthop_mat, ' ')
 
    csvwrite(strcat(basedir,'flooding_lasthop_rx_pkt_cnt', '','.csv'),rx_pkt_cnt_mat);
    dlmwrite(strcat(basedir, 'flooding_lasthop_rx_pkt_cnt.mat'), rx_pkt_cnt_mat, ' ')

    csvwrite(strcat(basedir,'flooding_lasthop_tx_pkt_cnt', '','.csv'),tx_pkt_cnt);
    dlmwrite(strcat(basedir, 'flooding_lasthop_tx_pkt_cnt.mat'), tx_pkt_cnt, ' ')

    csvwrite(strcat(basedir,'flooding_lasthop_fwd_pkt_cnt', '','.csv'),fwded_pkt_cnt_mat)
    dlmwrite(strcat(basedir, 'flooding_lasthop_fwd_pkt_cnt.mat'), fwded_pkt_cnt_mat, ' ')

    dlmwrite(strcat(basedir, 'flooding_lasthop_fwd_pkt_links.mat'), fwd_links, ' ')

    dlmwrite(strcat(basedir, 'flooding_responsibility_count.mat'), response_cnt_mat, ' ')

end

end