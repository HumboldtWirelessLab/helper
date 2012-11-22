
% Author: kuehne@informatik.hu-berlin.de
% Purpose: Find bridges and aculations

%clear all;
%close all;


function get_bridges_and_articulation_points(graphfile, basedir, params)

graph = load(graphfile);

% store original cluster size
cluster_size = cnt_partitions(graph);

bridges=[];

for i = 1:size(graph,1)-1
	for j = (i+1):size(graph,1)
		a=graph(i,j);
		b=graph(j,i);
		
		if ((a~=0)||(b~=0))
		    % delete edge
		    graph(i,j) = 0;
		    graph(j,i) = 0;
		
		    if (cluster_size < cnt_partitions(graph) )
			bridges = [bridges [i,j]];
		    end
		    graph(i,j) = a;
		    graph(j,i) = b;
		end
	end
end

csvwrite(strcat(basedir,'/bridges_',params,'.csv'),bridges);
%disp(bridges);

artp=[];

for i = 1:size(graph,1)
	a=graph(i,:);
	b=graph(:,i);
	graph(i,[1:end]) = 0;
	graph([1:end],i) = 0;

	if ((cluster_size+1) < cnt_partitions(graph))
		artp = [artp i];
	end
	
	graph(i,:) = a;
	graph(:,i) = b;
end

csvwrite(strcat(basedir,'/articulation_points_',params,'.csv'),artp);
%disp(artp);

end
