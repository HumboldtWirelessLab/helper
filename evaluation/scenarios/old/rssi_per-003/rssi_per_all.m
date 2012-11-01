% render all plots
for i=1:15
    rssi_per(strcat( num2str(i), '_sender.dat'), strcat( num2str(i), '_receiver.dat'));
end

rssi_per_together();
