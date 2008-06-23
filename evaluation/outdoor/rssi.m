s = load("rssi.own.all");
s(find(s(:) > 60))=0;
me = mean(s)
st = std(s)

