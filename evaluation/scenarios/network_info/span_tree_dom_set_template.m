function span_tree_dom_set_template(graphfile)

graph = load(graphfile);

min_pdr = 1;

% trim links according to mininum pdr
graph(find(graph < min_pdr))  = 0;
graph(find(graph >= min_pdr)) = 1;


% make graph symmetric
for row=1:size(graph,1),
	for col=row:size(graph,2)
		if (col ~= row)
			graph(row, col) = max(graph(row, col), graph(col, row));
			graph(col, row) = graph(row, col);
		end
	end
end

%                          adj, min_pdr, start_node
spanning_tree = span_tree(graph, -1,      1);

ds = dom_set(spanning_tree);

ds
