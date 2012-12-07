function st_test(graphfile, min_pdr, start_node)

% load graph
gr = load(graphfile);

% 'delete' edges with PDRs smaller than required by min_pdr, set others to 1
gr(find(gr < min_pdr)) = 0;
gr(find(gr ~= 0)) = 1;

% make graph symmetric
gr = gr + gr';
gr(find(gr ~= 0)) = 1;


% create descending node degree table
node_degree = [1:size(gr,1)]';

for i = 1:size(node_degree,1)
	node_degree(i,2) = sum(gr(node_degree(i,1),:));
end

node_degree = sortrows(node_degree,-2);


