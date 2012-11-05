function pretty_graph(CL_ID, gr, basedir)

%    addpath(path,'./graphviz');

    disp('Loading ...');

    if (0)
        gr = zeros(8, 8);
        gr(1,2) = 1;
        gr(2,3) = 1;
        gr(2,4) = 1;
        gr(3,2) = 1;
        gr(3,4) = 1;
        gr(4,2) = 1;
        gr(4,3) = 1;
        gr(4,5) = 1;
        gr(4,6) = 1;
        gr(5,4) = 1;
        gr(6,4) = 1;
        gr(6,7) = 1;
        gr(7,6) = 1;
        gr(7,8) = 1;
        gr(8,7) = 1;
    end

    % make graph symmetric
    for row=1:size(gr,1)
        for col=row:size(gr,2)
            if (col ~= row)
                gr(row, col) = max(gr(row, col), gr(col, row));
                gr(col, row) = gr(row, col);
            end
        end
    end

    all_nodes = 1:size(gr,1);
    open_nodes = 1:size(gr,1);

    max_cliques = maximalCliques2(gr);

    [v, id] = sort(sum(max_cliques), 'descend');

    idx = 1;
    idxN = 1;
    gr_ng = {};
    gr_ng_labels = {};

    while (~isempty(open_nodes))

        node_ids = all_nodes' .* max_cliques(:, id(idx));
        node_ids(node_ids == 0) = [];

        % check if node_ids is contained in open_nodes
        if (sum(ismember(open_nodes, node_ids)) == size(node_ids,1))
            open_nodes = setdiff(open_nodes, node_ids);
            gr_ng{idxN} = node_ids;
            gr_ng_labels{idxN} = int2str(node_ids');
            idxN = idxN + 1;
        end

        idx = idx + 1;

        if (idx >= size(id,2))
            break;
        end
    end

    % add remaining open nodes
    for ii=1:size(open_nodes,2)
        gr_ng{idxN} = open_nodes(ii);
        gr_ng_labels{idxN} = int2str(open_nodes(ii));
        idxN = idxN + 1;    
    end

    % create new adjacency matrix

    adj_ng = zeros(size(gr_ng,2), size(gr_ng,2));

    for row=1:size(adj_ng,1)
        % nbs of this hyper node
        if (size(gr_ng{row},1) > 1)
            nbs = find(sum(gr(gr_ng{row},:)) > 0);
        else
            nbs = find(gr(gr_ng{row},:) > 0);
        end
        nbs = setdiff(nbs, gr_ng{row});
        % place edge to each of them
        for ii=1:size(nbs,2)
            for kk=1:size(gr_ng,2)
                if (sum(ismember(gr_ng{kk}, nbs(ii))) == 1)
                    adj_ng(row, kk) = 1;
                end
            end
        end
    end

    % new adjacency matrix
    adj_ng

    % create dot file
    draw_dot(CL_ID, adj_ng, gr_ng_labels, basedir);
end