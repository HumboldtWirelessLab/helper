function metric2graph(graphfile, finalfileprefix)

g=load(graphfile,'-ASCII');

%00-00-00-00-00-3B,00-00-00-00-00-28,100,1,0,0,0,0,11
%00-00-00-00-00-3B,00-00-00-00-00-2B,100,1,0,0,0,0,25

NODES=sort(unique(g(:,1)));
SIZES=sort(unique(g(:,3)));
RATES=sort(unique(g(:,4)));

for s = 1:size(SIZES,1)
 n_s = SIZES(s);

 for r = 1:size(RATES,1)
  n_r = RATES(r);

  res = zeros(size(NODES,1),size(NODES,1));
  rs_g = g(find((g(:,3)==n_s) & (g(:,4)==n_r)),:);

  for a = 1:size(NODES,1)
    n_a=NODES(a);

    for b = 1:size(NODES,1)
      n_b=NODES(b);

      r=find((rs_g(:,1)==n_a) & (rs_g(:,2)==n_b));
      if ( ~isempty(r) )
        res(n_a,n_b)=min(rs_g(r,9));
      end
    end
  end

  csvwrite(strcat(finalfileprefix, 'graph_psr_', num2str(n_r), '_', num2str(n_s), '.csv'),res);

 end
end

end
