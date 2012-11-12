function crcerror_plot(psize, bitrate, interval, packetfile, bitfile)

r=load(packetfile);

r( find( r(:,7) > 60 ),7) = 0;

r( find( r(:,4) ~= psize ),3) = 0;   %all foreign, which don't match to the given Packetsize
r( find( r(:,5) ~= bitrate ),3) = 0; %all foreign, which don't match to the given Bitrate
r( find( r(:,2) ~= 0 ),3) = 0;       %all foreign, which are not correct
	
own_rec = r( find( r(:,3) == 1 ),:);
own_rec_ok = own_rec(find( own_rec(:,2) == 0 ),:);
 
first_packet_id = own_rec_ok(1,6);
last_packet_id = own_rec_ok(end,6);
first_packet_time = own_rec_ok(1,1);
start_time = r(1,1);
end_time = r(end,1);
possible_start_id = first_packet_id - floor ( ( ( first_packet_time - start_time) * 1000 ) / interval );
possible_end_id = last_packet_id + floor ( ( ( end_time - own_rec_ok(end,1) ) * 1000 ) / interval );
possible_first_id_time = first_packet_time - ( ( ( possible_start_id - first_packet_id ) * interval ) / 1000 );

allp=load(packetfile);

myp=allp((find((allp(:,3)==1) & (allp(:,4)==psize) & (allp(:,5)==bitrate) & ( (allp(:,6) >= possible_start_id )) & ( (allp(:,6) <= possible_end_id )))),[2 6]);

pidstate=[ possible_start_id:possible_end_id ]';
pidstate=[pidstate zeros(size(pidstate,1),1)];

for i=1:size(pidstate,1)
	state=find((myp(:,2)==pidstate(i,1)) & ( myp(:,1)==1));           %got crc_errors
	if ( ~isempty(state) )
	    if ( size(state,1) > 1 )
		pidstate(i,2)=2;
	    else
		pidstate(i,2)=3;
	    end
	end    

	state=find((myp(:,2)==pidstate(i,1)) & ( myp(:,1)==0));
	if ( ~isempty(state))
		pidstate(i,2)=1;
	end
	
end

clear r
r=load(bitfile);
err=r(find( (r(:,4) == 1)  & ( r(:,2)  >= possible_start_id ) & ( r(:,2)  <= possible_end_id ) ),2:3);

if ( ~isempty(err) & (size(err,1) ~= 0 ) )
   plot(err(:,2),err(:,1),'r.');
   xlabel('Bitposition');
   ylabel('Packet-ID');
   crctitle=strcat('Biterror ( ', num2str(size(unique(err(:,1)),1)),' Packets)' );
   title(crctitle);
   fname = strcat(bitfile,'.png');
   print('-dpng', fname);
end

clear alllost;
alllost=pidstate(find(pidstate(:,2) == 0));

%lostsize=size(alllost)
%allppackets=possible_end_id-possible_start_id
%per=lostsize/allppackets

for i=1:size(alllost,1)
	line( [ 0 ( (psize - 32 ) * 8 )] , [ alllost(i,1) alllost(i,1) ] );
end

xlabel('Bitposition');
ylabel('Packet-ID');
crctitle=strcat('Biterror ( ', num2str(size(unique(err(:,1)),1)),' Packets)' );
title(crctitle);
    
fname = strcat(bitfile,'_big.png');
print('-dpng', fname);

end

