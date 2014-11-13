function partitionplacement(clusterfile, placementfile, finalfile)

c=load(clusterfile,'-ASCII');
p=load(placementfile,'-ASCII');

size(c)
size(p)
cpmat=p(c,:);

cpmat=[ [1:size(c)]' cpmat];

csvwrite(finalfile,cpmat);

end