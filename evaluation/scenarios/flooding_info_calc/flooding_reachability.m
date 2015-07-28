function flooding_reachability( filename, basedir )
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

RCV_CNT=18;

  data=load(filename,'-ASCII');

  nodes=unique(data(:,SRCNODE)); 
  allnodes=unique(data(:,NODE));

  for i = 1:size(nodes,1)
     reach=zeros(max(allnodes),2);
     node=nodes(i);
     rx1=data((data(:,SRCNODE)==node),:);
     packets=max(rx1(:,PKTCNT)) %src

     for a = 1:size(allnodes,1)     %last
        %rxpackets=unique(data((data(:,3)==node) & (data(:,2)==allnodes(a)),11));
        rxpackets=unique(rx1((rx1(:,NODE)==allnodes(a)),ID));

        reach(allnodes(a),1) = allnodes(a);
        if isempty(rxpackets)
          reach(allnodes(a),2)=0;
        else
          reach(allnodes(a),2)=size(rxpackets,1)/packets;
        end
     end

     reach(:,2)=reach(:,2)*100;

     csvwrite(strcat(basedir,'flood_reach', '','.csv'),reach);
     dlmwrite(strcat(basedir,'flood_reach.mat'),reach, ' ');
  end

end

