function metric2graph(graphfile, finalfile, min_metric)
g=load(graphfile,'-ASCII');

NODES=sort(unique(g(:,1)));

res=zeros(size(NODES,1),size(NODES,1));


for a = 1:size(NODES,1)
  n_a=NODES(a);
  for b = 1:size(NODES,1)
    n_b=NODES(b);
    r=find((g(:,1)==n_a) & (g(:,2)==n_b));
    if ( ~isempty(r) )
      res(n_a,n_b)=min(g(r,3));
    end
  end
end

res(res>min_metric)=0;
res(res>0)=1;

csvwrite(finalfile,res);

end
