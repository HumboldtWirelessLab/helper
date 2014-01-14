a=load('floodingforwardstats.mat');

nodes=unique(a(:,2));
pkts=unique(a(:,10))

for n=1:size(nodes)

  node = nodes(n);
  ids = unique(a(find(a(:,2) == node),11));    %welche id hat der Knoten

  if ( size(ids,1) ~= pkts )
    z=zeros(pkts,1);
    z(ids)=1;
    missed_ids=find(z(:) == 0);
    for mi = 1:size(missed_ids,1)
      node
      missed_id = missed_ids(mi)
      %resp = a(find((a(:,11)==missed_ids(mi)) & (a(:,15)==1)),2)
      %ack = a(find((a(:,11)==missed_ids(mi)) & (a(:,1)==node) & ((a(:,17)~=0) | a(:,18)~=0)),:)
      has_as_last_node = a(find((a(:,11)==missed_ids(mi)) & (a(:,1)==node)),:)
    end
  end

end
