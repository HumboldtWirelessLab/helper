function flooding2pdr( filename, basedir )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

  data=load(filename,'-ASCII');

  nodes=unique(data(:,3)); 
  allnodes=unique(data(:,2));

  for i = 1:size(nodes,1)
     pdr_mat=zeros(max(allnodes),max(allnodes));
     pdr_hop_mat=zeros(max(allnodes),max(allnodes));
     pdr_hop_pkt_cnt_mat=zeros(max(allnodes),max(allnodes));
     node=nodes(i);
     packets=max(data(data(:,3)==node,10)); %src

     for a = 1:size(allnodes,1)     %last
         for b = 1:size(allnodes,1) %dst
            rxpackets=data((data(:,3)==node) & (data(:,1)==allnodes(a)) & (data(:,2)==allnodes(b)),11);
            lastpackets=unique(data((data(:,3)==node) & (data(:,2)==allnodes(a)),11));

            if isempty(rxpackets)
                pdr=0;
                hop_pdr=0;
                pkts=0;
            else
                pdr=size(rxpackets,1)/packets;
                hop_pdr=size(rxpackets,1)/size(lastpackets,1);
                pkts=size(lastpackets,1);
            end
            pdr_mat(allnodes(a),allnodes(b))=pdr;
            pdr_hop_mat(allnodes(a),allnodes(b))=hop_pdr;
            pdr_hop_pkt_cnt_mat(allnodes(a),allnodes(b))=pkts;
         end
     end

     pdr_mat=round(100*pdr_mat);
     pdr_hop_mat=round(100*pdr_hop_mat);

     csvwrite(strcat(basedir,'flood2src_pdr', '','.csv'),pdr_mat);
     csvwrite(strcat(basedir,'flood2hop_pdr', '','.csv'),pdr_hop_mat);
     csvwrite(strcat(basedir,'flood2hop_pkt_cnt', '','.csv'),pdr_hop_pkt_cnt_mat);
  end

end

