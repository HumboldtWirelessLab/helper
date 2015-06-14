function metric2graph(graphfile, finalfile, min_metric)

g=load(graphfile,'-ASCII');

nonodes=max(g(:,1));

res=zeros(nonodes,nonodes);

g = g((g(:,3) > 0) & (g(:,3) <= min_metric),:);

v = g(:,1) * nonodes + g(:,2) - (nonodes);

res(v) = 1;

dlmwrite(strcat(finalfile,'.csv'), res, ',')
dlmwrite(strcat(finalfile,'.mat'), res, ' ')

end
