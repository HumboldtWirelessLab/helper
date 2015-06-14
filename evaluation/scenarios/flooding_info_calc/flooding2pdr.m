function flooding2pdr( filename, basedir )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
LASTNODE=1;
NODE=2;
SRCNODE=3;
PKTSIZE=4;
PKTCNT=10;

ID=11;
FWD_CNT=12;
SENT_CNT=13;

RCV_CNT=18;

  data=load(filename,'-ASCII');

  nodes=unique(data(:,SRCNODE)); 
  allnodes=unique(data(:,NODE));

  max_nodes= max(allnodes);
  
  for i = 1:size(nodes,1)

     pdr_mat=zeros(max_nodes,max_nodes);                  %overall pdr (src to node)
     tx_pdr_lasthop_mat=zeros(max_nodes,max_nodes);       %pdr tx last hop
     fwd_pdr_lasthop_mat=zeros(max_nodes,max_nodes);      %pdr fwd last hop
     pdr_hop_tx_pkt_cnt_mat=zeros(max_nodes,max_nodes);
     pdr_hop_fwd_pkt_cnt_mat=zeros(max_nodes,max_nodes);

     node=nodes(i);
     
     data3=data(data(:,SRCNODE)==node,:);   %quellknoten
     data3s=data3(data3(:,SENT_CNT) > 0,:); %infos zu sent
     data3r=data3(data3(:,RCV_CNT) > 0,:);  %infos zu rx
     data3f=data3(data3(:,FWD_CNT) > 0,:);  %infos zu fwd
        
     packets=max(data3(:,PKTCNT));          %pkt ids

     for a = 1:size(allnodes,1)             %last
         allnodes(a)
         lastpackets_sent=unique(data3s(data3s(:,NODE)==allnodes(a),SENT_CNT));
         sum(lastpackets_sent)
         lastpackets_fwd=unique(data3f(data3f(:,NODE)==allnodes(a),SENT_CNT));
         rx1=data3r(data3r(:,LASTNODE)==allnodes(a),:);
         
         for b = 1:size(allnodes,1)         %dst
             
            rxpackets=rx1(rx1(:,NODE)==allnodes(b),ID); %lasthop
            
            %rxpackets=data((data(:,3)==node) & (data(:,1)==allnodes(a)) & (data(:,2)==allnodes(b)),11); %lasthop

            %lastpackets_sent=unique(data((data(:,3)==node) & (data(:,2)==allnodes(a)) & (data(:,13)==1),11));
            %lastpackets_fwd=unique(data((data(:,3)==node) & (data(:,2)==allnodes(a)) & (data(:,12)==1),11));

            if isempty(rxpackets)
                pdr=0;
                lasthop_tx_pdr=0;
                lasthop_fwd_pdr=0;
            else
                pdr=size(rxpackets,1)/packets;

                if isempty(lastpackets_sent)
                    if isempty(lastpackets_fwd)
                      lasthop_tx_pdr=0;
                    else
                      lasthop_tx_pdr=size(rxpackets,1)/size(lastpackets_fwd,1);
                    end
                else
                    lasthop_tx_pdr=size(rxpackets,1)/size(lastpackets_sent,1);
                end

                if isempty(lastpackets_fwd)
                  lasthop_fwd_pdr=0;
                else
                  lasthop_fwd_pdr=size(rxpackets,1)/size(lastpackets_fwd,1);
                end
            end

            if ~isempty(lastpackets_sent)
                pkts=size(lastpackets_sent,1);
            else
                pkts=0;
            end

            if ~isempty(lastpackets_fwd)
                fwd_pkts=size(lastpackets_fwd,1);
            else
                fwd_pkts=0;
            end

            pdr_mat(allnodes(a),allnodes(b))=pdr;
            tx_pdr_lasthop_mat(allnodes(a),allnodes(b))=lasthop_tx_pdr;
            fwd_pdr_lasthop_mat(allnodes(a),allnodes(b))=lasthop_fwd_pdr;
            pdr_hop_tx_pkt_cnt_mat(allnodes(a),allnodes(b))=pkts;
            pdr_hop_fwd_pkt_cnt_mat(allnodes(a),allnodes(b))=fwd_pkts;
         end
     end

     
     %pkt_fwd=unique(data((data(:,3)==node) & (data(:,12)==1),11));


     pdr_mat=100*pdr_mat;
     tx_pdr_lasthop_mat=100*tx_pdr_lasthop_mat;
     fwd_pdr_lasthop_mat=100*fwd_pdr_lasthop_mat;

     csvwrite(strcat(basedir,'flooding_src_pdr', '','.csv'),pdr_mat);
     csvwrite(strcat(basedir,'flooding_lasthop_tx_pdr', '','.csv'),tx_pdr_lasthop_mat);
     csvwrite(strcat(basedir,'flooding_lasthop_fwd_pdr', '','.csv'),fwd_pdr_lasthop_mat);
     csvwrite(strcat(basedir,'flooding_lasthop_tx_pkt_cnt', '','.csv'),pdr_hop_tx_pkt_cnt_mat);
     csvwrite(strcat(basedir,'flooding_lasthop_fwd_pkt_cnt', '','.csv'),pdr_hop_fwd_pkt_cnt_mat);
  end

end

