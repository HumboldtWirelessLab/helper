function seismo(filename)

%function collaborative_detector(events, detected, offset, range)

offset=0;
range=500;

data = load(filename);

nodes=unique(data((data(:,2) ~= 254),2))

events=data((data(:,2) = 254),4)


for i = 0:size(nodes,1)
  n=nodes(i);

  detected=data((data(:,2) = n),4);

  collaborative_detector(events, detected, offset, range)

end

end
