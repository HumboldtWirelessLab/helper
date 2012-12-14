function partitionplacement(clusterfile, placementfile, finalfile)

c=load(clusterfile);
p=load(placementfile);

cpmat=p(c,:);

cpmat=[ [1:size(c)]' cpmat];

csvwrite(finalfile,cpmat);

end