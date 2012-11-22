
% Author: kuehne@informatik.hu-berlin.de
% Purpose: Find bridges and aculations

%clear all;
%close all;


function get_bridges(graphfile)

graph = load(graphfile);

% store original cluster size
cluster_size = cnt_partitions(graph);

[m,n] = size(graph);
head = 2;

for i = 1:m-1
	tmp_graph = graph;
	
	for j = head:n
		% delete edge
		tmp_graph(i,j) = 0;
		tmp_graph(j,i) = 0;
		
		if (cluster_size < cnt_partitions(tmp_graph) )
			bridges = [bridges [i,j]];
		end
	end
	head += 1;
end

disp(bridges);

end
