function flooding2pdr( filename, basedir )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

  data=load(filename,'-ASCII');

  nodes=unique(data(:,3)); 
  allnodes=unique(data(:,2));

  for i = 1:size(nodes,1)

     pdr_mat=zeros(max(allnodes),max(allnodes));
     tx_pdr_lasthop_mat=zeros(max(allnodes),max(allnodes));
     fwd_pdr_lasthop_mat=zeros(max(allnodes),max(allnodes));
     pdr_hop_tx_pkt_cnt_mat=zeros(max(allnodes),max(allnodes));
     pdr_hop_fwd_pkt_cnt_mat=zeros(max(allnodes),max(allnodes));

     node=nodes(i);

     packets=max(data(data(:,3)==node,10)); %src

     for a = 1:size(allnodes,1)     %last
          pkt_fwd=unique(data((data(:,3)==node) & (data(:,12)==1),11));

         for b = 1:size(allnodes,1) %dst

            rxpackets=data((data(:,3)==node) & (data(:,1)==allnodes(a)) & (data(:,2)==allnodes(b)),11); %lasthop

            lastpackets_sent=unique(data((data(:,3)==node) & (data(:,2)==allnodes(a)) & (data(:,13)==1),11));
            lastpackets_fwd=unique(data((data(:,3)==node) & (data(:,2)==allnodes(a)) & (data(:,12)==1),11));

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

     
     pkt_fwd=unique(data((data(:,3)==node) & (data(:,12)==1),11));


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

