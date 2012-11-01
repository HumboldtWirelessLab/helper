function nodedegree(vertices, edges, basedir)

  v=load(vertices);
  e=load(edges);
  
  degree=zeros(size(v,1),1);
  
  for i = 1:size(v,1)
      %e(i,:)
      %find(e(i,:) == 1)
      degree(i) = size(find(e(v(i),:) == 1),2);
  end
  
  degree
  
  hist(degree,max(degree));
  xlabel('Node degree');
  ylabel('#nodes');
  title(strcat('Node degree (', num2str(size(v,1)), ' nodes)'));
  
  print(strcat(basedir,'nodedegree.png'),'-dpng');
  
  csvwrite(strcat(basedir,'nodedegree.csv'),[ [ 1:(size(v,1))]' degree ]);
  
end