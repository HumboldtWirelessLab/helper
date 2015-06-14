function nodedegree(vertices, edges, basedir, id)

  v=load(vertices,'-ASCII');
  e=load(edges,'-ASCII');

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
  title(strcat('Node degree (', num2str(size(v,1)), ' nodes (Cluster ', num2str(id), '))'));

  print(strcat(basedir,'nodedegree_cluster_', num2str(id),'.png'),'-dpng');

  csvwrite(strcat(basedir,'nodedegree_cluster_', num2str(id),'.csv'),[ [ 1:(size(v,1))]' degree ]);

end