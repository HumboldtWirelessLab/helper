function rssi_per(channel,resultpath)
    
    if ( channel >= 0 )
	sendfile=strcat(resultpath,"/",int2str(channel),"/sendpack.dat");
    else
	sendfile=strcat(resultpath,"/sendpack.dat");
    end

    sender = load(sendfile);
    
    res=zeros(15,6);
    for i=1:15
	if ( channel >= 0 )
	    datname=strcat(resultpath,"/",int2str(channel),"/snr_",int2str(i),".dat");
	else
	    datname=strcat(resultpath,"/snr_",int2str(i),".dat");
	end
	
	a=load(datname);
	receivepack=length(a);
	res(i,1) = i;
	res(i,2) = sender(i,2);
	res(i,3) = receivepack;
	res(i,4) = ( 1 - ( res(i,3) / res(i,2) ) );
	res(i,5) = mean(a);
	res(i,6) = std(a);	
    end
    
    figure
    plot(res(:,5),res(:,4))
    title('Mean RSSI vs. PER');
    xlabel('Mean RSSI');
    ylabel('PER');
    
    if ( channel >= 0 )
        datname=strcat(resultpath,"/",int2str(channel),"/rssi_vs_per.png");
    else
	datname=strcat(resultpath,"/rssi_vs_per.png");
    end
    print(datname,'-dpng')
    
    figure
    plot(res(:,1),res(:,5))
    title('Sender TXPower vs. Mean RSSI')
    xlabel('TXPower (Sender)');
    ylabel('RSSI (Receiver)');
    if ( channel >= 0 )
        datname=strcat(resultpath,"/",int2str(channel),"/txpower_vs_rssi.png");
    else
	datname=strcat(resultpath,"/txpower_vs_rssi.png");
    end
    print(datname,'-dpng')
    
    figure
    plot(res(:,5),res(:,6))
    title('Mean RSSI vs. std RSSI')
    xlabel('Mean RSSI');
    ylabel('Standard deviation RSSI');
    if ( channel >= 0 )
        datname=strcat(resultpath,"/",int2str(channel),"/mean_rssi_vs_std_rssi.png");
    else
	datname=strcat(resultpath,"/mean_rssi_vs_std_rssi.png");
    end
    print(datname,'-dpng')
    
    figure
    plot(res(:,1),res(:,4))
    title('Sender TXPower vs. PER')
    xlabel('TXPower (Sender)');
    ylabel('PER');
    if ( channel >= 0 )
        datname=strcat(resultpath,"/",int2str(channel),"/txpower_vs_per.png");
    else
	datname=strcat(resultpath,"/txpower_vs_per.png");
    end
    print(datname,'-dpng')
    
end