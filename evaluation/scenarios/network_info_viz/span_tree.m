function span_adj = span_tree(adj, min_pdr, start_node)

checked = [start_node];
not_checked = [start_node];

span_adj = zeros(size(adj, 2));


while (~isempty(not_checked))

	nbs = [];

	node = not_checked(1,1);

	% delete current node from ToDo List
	not_checked(1, :) = [];

	% get 1 hops of current node
	for i = 1:size(adj, 2)
		if (adj(node, i) == 1)
			nbs = union(nbs, i);
		end
	end

	% ignore neighbours that are already part of the spanning tree
	nbs = setdiff(nbs, checked);


	if (~isempty(nbs))   % there are 1 hops that we haven't got already

		% make nbs Nx1
		if (size(nbs, 1) == 1)
			nbs = nbs';
		end

		% get node degrees of 1 hops
		for i = 1:size(nbs, 1)
			nbs(i, 2) = sum(adj(nbs(i, 1), :));
		end

		% sort 1 hops descending by node degree
		nbs = sortrows(nbs, -2);

		% node degree only relevant for sorting
		nbs(:, 2) = [];

		% set edge in the spanning tree for every new neighbour
		for i = 1:size(nbs, 1)
			span_adj(node, nbs(i)) = 1;
		end

		% append new nodes/1 hops to ToDo list
		not_checked = [not_checked; nbs];

		checked = union(checked, nbs);

	end


end
