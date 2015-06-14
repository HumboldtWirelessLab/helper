function nodedegree(graphfile, psr, finalfileprefix)

g=load(graphfile,'-ASCII');

for i=1:size(psr,2)
  h = g;
  h(h(:) < psr(i)) = 0;
  h(h(:)~=0) = 1;

  h = sum(h);
   
  [N,BIN] = histc(h,[min(h):max(h)]);
  histogram = [[min(h):max(h)]; N];
  
  dlmwrite(strcat(finalfileprefix, 'nodedegree_hist_psr_', num2str(psr(i)) ,'.mat'), histogram', ' ');
  dlmwrite(strcat(finalfileprefix, 'nodedegree_psr_', num2str(psr(i)) ,'.mat'), h', ' ');

 end

end
