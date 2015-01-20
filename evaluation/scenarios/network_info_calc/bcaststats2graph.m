function metric2graph(graphfile, finalfileprefix)

g=load(graphfile,'-ASCII');

%00-00-00-00-00-3B,00-00-00-00-00-28,100,1,0,0,0,0,11
%00-00-00-00-00-3B,00-00-00-00-00-2B,100,1,0,0,0,0,25

nonodes=max(g(:,1));
SIZES=sort(unique(g(:,3)));
RATES=sort(unique(g(:,4)));

for s = 1:size(SIZES,1)
 n_s = SIZES(s);

 for r = 1:size(RATES,1)
  n_r = RATES(r);

  res = zeros(nonodes,nonodes);
  rs_g = g(find((g(:,3)==n_s) & (g(:,4)==n_r)),:);

  for i = 1:size(rs_g,1)
      res(rs_g(i,1),rs_g(i,2)) = rs_g(i,9);
  end

  dlmwrite(strcat(finalfileprefix, 'graph_psr_', num2str(n_r), '_', num2str(n_s), '.csv'), res, ',')
  dlmwrite(strcat(finalfileprefix, 'graph_psr_', num2str(n_r), '_', num2str(n_s), '.mat'), res, ' ')

  if ((s == 1) && (r==1))
    dlmwrite(strcat(finalfileprefix, 'graph_psr.mat'), res, ' ')
  end

 end
end

end
