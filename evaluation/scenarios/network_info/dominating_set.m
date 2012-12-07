function dom_set = dominating_set(graphfile, min_pdr, start_node)

% add path to Torsche Scheduling Toolbox
addpath(path, './scheduling');

% load graph
gr = load(graphfile);

% 'delete' edges with PDRs smaller than required by min_pdr, set others to 1
gr(find(gr < min_pdr)) = 0;
gr(find(gr ~= 0)) = 1;


% make graph symmetric
gr = gr + gr';
gr(find(gr ~= 0)) = 1;


% set 0's to Infs for graph()
gr(find(gr == 0)) = Inf;

% create graph object
gr = graph(gr);


% create minimal spanning tree of the graph object
span_tree_tmp = spanningtree_with_startnode(gr, start_node);


% extract actual spanning tree as a matrix from the spanning tree graph object
span_tree = span_tree_tmp.adj;

span_tree

% trim leafes of the spanning tree to get the dominating set
dom_set = [];

% additional info
not_dom_set = [];
not_in_span_tree = [];

for i = 1:size(span_tree, 2)   % for each column
	degree = sum(span_tree(:,i));

	if (degree > 1) % 
		dom_set = union(dom_set, i);
	end

	if (degree == 1)
		not_dom_set = union(not_dom_set, i);
	end

	if (degree < 1)
		not_in_span_tree = union(not_in_span_tree, i);
	end

end

% not_in_span_tree
% not_dom_set

