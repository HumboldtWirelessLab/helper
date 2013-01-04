function ds = dom_set(span_adj)

ds = [];

for i = 1:size(span_adj, 1)

	edge_sum = sum(span_adj(i, :));

	if (edge_sum > 1)
		ds = union(ds, i);
	end
end
