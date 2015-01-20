function nodedegree_plot(graphfile, psr, finalfileprefix)

g=load(graphfile,'-ASCII');

for i=1:size(psr,2)
  h = g;
  h(h(:) < psr(i)) = 0;
  h(h(:)~=0) = 1;

  h = sum(h);

  figure;
  hist(h,max(h)-min(h)+1)
  print(strcat(finalfileprefix, 'nodedegree_hist_psr_', num2str(psr(i)), '.png'),'-dpng');
  print(strcat(finalfileprefix, 'nodedegree_hist_psr_', num2str(psr(i)), '.eps'),'-deps');
  
  figure;
  cdfplot(h)
  print(strcat(finalfileprefix, 'nodedegree_cdf_psr_', num2str(psr(i)), '.png'),'-dpng');
  print(strcat(finalfileprefix, 'nodedegree_cdf_psr_', num2str(psr(i)), '.eps'),'-deps');
  
  %[N,BIN] = histc(h,[min(h):max(h)]);
  %histogram = [[min(h):max(h)]; N]
 
  %figure;
  %bar(histogram(1,:),histogram(2,:));

end

end

