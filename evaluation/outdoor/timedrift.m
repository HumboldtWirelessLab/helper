function timedrift(datfile,psize,interval)

%laden und alle pakete mit 1 Mbit und size als grösse
p=load(datfile);
onemb=p(find((p(:,2) == 0) & (p(:,3) == 1) & (p(:,5) == 1) & (p(:,4) == psize)),:);

coronemb=onemb(:,1);

%zeit relativ zum ersten paket
onemb(:,1)=onemb(:,1)-onemb(1,1);

%ids relativ zur ersten
onemb(:,6)=onemb(:,6)-onemb(1,6);

coronemb=[ coronemb onemb ];

onemb(:,1)=onemb(:,1) - (onemb(:,6) * (interval/1000));

ert=[];
meantime=[];
for i=onemb(1,6):onemb(end,6)
   ac_times=onemb(find( onemb(:,6) == i),1);
   if ~isempty(ac_times)
      meantime=[ meantime ; [ mean(ac_times(:,1)) i ] ];
  end
  ert=[ ert ; [ ((interval/1000) * i) i ] ];
end

plot(meantime(:,2),meantime(:,1))
xlabel('PacketID');
ylabel('Timediff Sender/Receiver');
print('-dpng', 'timedrift.png');

mtd=meantime(:,1) ./ meantime(:,2);
mtd(1) = mtd(3);

%plot(ert(:,2),ert(:,1))

coronemb(:,1)=coronemb(:,1) - ( mean(mtd) * coronemb(:,7) );
coronemb(:,1)=coronemb(:,1) - coronemb(1,1);
coronemb(:,1)=coronemb(:,1) - coronemb(:,7) * (interval/1000);
coronemb(:,1)=floor(coronemb(:,1)*1000000);
coronemb(:,[1 7]);

%plot(coronemb(:,7),coronemb(:,1))

length(coronemb(:,7))

end
