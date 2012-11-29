function flooding_forward( filename, basedir )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

  data=load(filename,'-ASCII');

  nodes=unique(data(:,3)); 
  allnodes=unique(data(:,2));

  for i = 1:size(nodes,1)
     fwd_prob=zeros(max(allnodes),1);
     node=nodes(i);

     for a = 1:size(allnodes,1)     %last
        rxpackets=unique(data((data(:,3)==node) & (data(:,2)==allnodes(a)),11));
        fwdpackets=unique(data((data(:,3)==node) & (data(:,2)==allnodes(a)) & (data(:,12)==1),11));

        if isempty(rxpackets)
          fwd_prob(allnodes(a))=0;
        else
          fwd_prob(allnodes(a))=size(fwdpackets,1)/size(rxpackets,1);
        end
     end

     fwd_prob=fwd_prob*100;

     csvwrite(strcat(basedir,'flooding_forward_probability','.csv'),fwd_prob);

     hist(fwd_prob);
     xlabel('Forward Probability');
     ylabel('Count');
     title('Histogram Forward Probability');

     print(strcat(basedir,'flooding_forward_probability','.png'),'-dpng');

  end

end

