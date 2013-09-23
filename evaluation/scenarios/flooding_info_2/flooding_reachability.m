function flooding_reachability( filename, basedir )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

  data=load(filename,'-ASCII');

  nodes=unique(data(:,3)); 
  allnodes=unique(data(:,2));

  for i = 1:size(nodes,1)
     reach=zeros(max(allnodes),2);
     node=nodes(i);
     packets=max(data(data(:,3)==node,10)); %src

     for a = 1:size(allnodes,1)     %last
        rxpackets=unique(data((data(:,3)==node) & (data(:,2)==allnodes(a)),11));

        reach(allnodes(a),1) = allnodes(a);
        if isempty(rxpackets)
          reach(allnodes(a),2)=0;
        else
          reach(allnodes(a),2)=size(rxpackets,1)/packets;
        end
     end

     reach(:,2)=reach(:,2)*100;

     csvwrite(strcat(basedir,'flood_reach', '','.csv'),reach);
  end

end
