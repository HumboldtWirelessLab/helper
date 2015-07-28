function flooding_forward( filename, basedir )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%Use to terminate the forward probability. This is usefull to check
%algorithms like Probability-Flooding

LASTNODE=1;
NODE=2;
SRCNODE=3;
%PKTSIZE=4;
PKTCNT=10;

ID=11;
FWD_CNT=12;
SENT_CNT=13;
FORWARDED=14;

RCV_CNT=18;

  data=load(filename,'-ASCII');
  datas=data(data(:,FORWARDED)==1,:);
  
  nodes=unique(data(:,SRCNODE)); 
  allnodes=unique(data(:,NODE));

  for i = 1:size(nodes,1)
     fwd_prob=zeros(max(allnodes),1);
     node=nodes(i);

     rx1=data((data(:,SRCNODE)==node),:);
     rx1s=datas((datas(:,SRCNODE)==node),:);
     
     for a = 1:size(allnodes,1)     %last
        %rxpackets=unique(data((data(:,3)==node) & (data(:,2)==allnodes(a)),11));
        %fwdpackets=unique(data((data(:,3)==node) & (data(:,2)==allnodes(a)) & (data(:,12)==1),11));
        
        rxpackets=unique(rx1(rx1(:,NODE)==allnodes(a),ID));
        fwdpackets=unique(rx1s(rx1s(:,NODE)==allnodes(a),ID));
        
        if isempty(rxpackets)
          fwd_prob(allnodes(a))=0;
        else
          fwd_prob(allnodes(a))=size(fwdpackets,1)/size(rxpackets,1);
        end
     end

     fwd_prob=fwd_prob*100;

     csvwrite(strcat(basedir,'flooding_forward_probability','.csv'),fwd_prob);
     dlmwrite(strcat(basedir,'flooding_forward_probability.mat'),fwd_prob, ' ');

     h1 = figure;
     hist(fwd_prob);
     xlabel('Forward Probability');
     ylabel('Count');
     title('Histogram Forward Probability');

     saveas(h1, strcat(basedir,'flooding_forward_probability','.eps'),'epsc');
     %print(strcat(basedir,'flooding_forward_probability','.png'),'-dpng');

  end

end

