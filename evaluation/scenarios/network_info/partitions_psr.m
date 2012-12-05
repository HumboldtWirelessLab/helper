function partitions_psr(graphfile, psr, basedir)
%TODO: use recursive func
g=load(graphfile);

%size(g)


cluster = zeros(size(g,1),1);
cluster_id = 1;

while ( ~isempty(find(cluster(:) == 0)) )
    first = find(cluster(:) == 0);
    %first(1)
    cluster(first(1)) = cluster_id;

    changes=1;
    while ( changes==1 )
        changes=0;
        unused = find(cluster(:) == 0);
        used = find(cluster(:) == cluster_id);

        if ( ~isempty(unused) )
            for a = 1:size(used)
              for b = 1:size(unused)
                  if ((g(used(a),unused(b)) >= psr) && (g(unused(b),used(a)) >= psr))
                      cluster(unused(b)) = cluster_id;
                      changes = 1;
                  end
              end
            end
        end
    end

    cluster_id = cluster_id + 1;

end

cluster_size = zeros(cluster_id - 1,2);

cluster_size(:,1) = [1:cluster_id-1];
for c = 1:(cluster_id-1)
   cluster_size(c,2)=size(find(cluster(:) == c),1);
   clusteradjmat=g(find(cluster(:) == c),find(cluster(:) == c));
   csvwrite(strcat(basedir,'cluster_', num2str(c),'.csv'),find(cluster(:) == c));
   csvwrite(strcat(basedir,'clusteradjmat_', num2str(c),'.csv'),clusteradjmat);
end

%cluster_size
csvwrite(strcat(basedir,'clustersize.csv'),sortrows(cluster_size,2));
%cluster

end