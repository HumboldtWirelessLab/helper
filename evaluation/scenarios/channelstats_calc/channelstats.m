function [ output_args ] = channelstats( data )
%CHANNELSTATS Summary of this function goes here
%   Detailed explanation goes here

NODE=1;
TIME=2;
ID=3;
MAC_RX_PKT=4;
MAC_NO_ERR_PKT=5;
MAC_RX_BYTES=6;
MAC_TX_UNICAST=7;
MAC_TX_BCAST=8;
MAC_PERC_BUSY=9;
MAC_PERC_RX=10;
MAC_PERC_TX=11;
PHY_PERC_BUSY=12;
PHY_PERC_RX=13;
PHY_PERC_TX=14;
PHY_CHANNEL_TX=15;


nodes=unique(data(:,NODE));

nodes_result=zeros(size(nodes,1),3);

for n = 1:size(nodes,1)
    node_data=data(data(:,NODE)==nodes(n),:);
    nodes_result(n,1) = n;
    nodes_result(n,2) = mean(node_data(:,MAC_PERC_BUSY));
    nodes_result(n,3) = mean(node_data(:,PHY_PERC_BUSY));
end

%rxtxbusy_diff = data(:,PHY_PERC_BUSY) - (data(:,PHY_PERC_RX)+data(:,PHY_PERC_TX));
rxtxbusy_diff = data(:,PHY_PERC_BUSY) - data(:,MAC_PERC_BUSY);
err_rel = data(:,MAC_NO_ERR_PKT) ./ data(:,MAC_RX_PKT);

figure;
scatter(rxtxbusy_diff,err_rel);
figure;
scatter(data(:,PHY_PERC_BUSY),err_rel);

figure;
plot(nodes_result(:,1),nodes_result(:,2));
hold on;
plot(nodes_result(:,1),nodes_result(:,3),'r');

%boxplot(nodes,data(:,[NODE PHY_PERC_BUSY]));


end

