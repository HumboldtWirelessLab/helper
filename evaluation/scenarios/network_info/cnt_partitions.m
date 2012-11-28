function cluster_size = cnt_partitions(g)
%TODO: use recursive func

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
                  if ((g(used(a),unused(b)) == 1) || (g(unused(b),used(a)) == 1))
                      cluster(unused(b)) = cluster_id;
                      changes = 1;
                  end
              end
            end
        end
    end

    cluster_id = cluster_id + 1;

end
    cluster_size = cluster_id - 1;
end
