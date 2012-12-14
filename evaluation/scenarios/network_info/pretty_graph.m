function [gr_ng] = pretty_graph(CL_ID, gr, basedir, mygr, cl_nodes)

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
    %adj_ng



    % gr_ng only contains indices of the clique nodes in 'cl_nodes'
    % -> so find real node ids in cl_nodes with indices from gr_ng:

    clique = [];

    for hh = 1:size(gr_ng, 2)

        cl_nodes_indices = gr_ng{1,hh};

        for cc = 1:size(cl_nodes_indices, 1)
            clique = union(clique, cl_nodes(cl_nodes_indices(cc)));
        end
    end

    if (size(cl_nodes, 2) > 1)

        unneeded_nodes = [];

        for kk=1:size(gr_ng, 2) % for each clique

            % create node degree table for the clique
            nd_dgr = clique';

            for ll=1:size(nd_dgr,1)
                gr_index = find(cl_nodes == nd_dgr(ll,1));
                nd_dgr(ll,2) = sum(gr(gr_index,:));
            end

            nd_dgr = sortrows(nd_dgr,2);

            % find out which are nodes are reached by the nodes of the clique
            connected_nodes = [];

            % for each node in the clique
            for pp=1:size(clique, 2);

                % get index in gr from cl_nodes
                gr_node_index = find(cl_nodes == clique(pp));

                for qq=1:size(gr,2)

                    if ((gr(gr_node_index,qq) == 1) & ~(ismember(cl_nodes(qq), connected_nodes)))
                        connected_nodes = union(connected_nodes, cl_nodes(qq));
                    end
                end
            end

            % delete nodes from the clique in order of der node degree, starting with the ones with the least degree

            myclique = clique;

            % for each node build custom clique without it
            for rr=1:size(nd_dgr,1)
                clique_tmp          = myclique;
                clique_tmp          = setdiff(myclique, nd_dgr(rr, 1));

                connected_nodes_tmp = [];

                %find out which nodes are reached by the new clique (reduced by 1 node)
                for tt=1:size(clique_tmp, 2)

                    % get index in gr from cl_nodes
                    gr_node_index_tmp = find(cl_nodes == clique_tmp(tt));

                    for uu=1:size(gr,2)

                        if ((gr(gr_node_index_tmp, uu) == 1) & ~(ismember(cl_nodes(uu), connected_nodes_tmp)))
                           connected_nodes_tmp = union(connected_nodes_tmp, cl_nodes(uu));
                        end
                    end
                end

                % if connected nodes are the same, set the clique to the diminshed clique
                if (isequal(connected_nodes, connected_nodes_tmp) == 1)
                    myclique = clique_tmp;
                    unneeded_nodes = union(unneeded_nodes, nd_dgr(rr, 1));
                end

            end

        end

        unneeded_nodes

        if (size(unneeded_nodes,2) >= 1)

            % create 2nd new adjacency matrix, to be sure

            adj_ng2 = zeros(size(gr_ng,2), size(gr_ng,2));

            for row=1:size(adj_ng2,1)
                % nbs of this hyper node
                if (size(gr_ng{row},1) > 1)
                    nbs2 = find(sum(gr(gr_ng{row},:)) > 0);
                else
                    nbs2 = find(gr(gr_ng{row},:) > 0);
                end
                nbs2 = setdiff(nbs2, gr_ng{row});
                % place edge to each of them
                for ii=1:size(nbs2,2)
                    for kk=1:size(gr_ng,2)
                        if (sum(ismember(gr_ng{kk}, nbs2(ii))) == 1)
                            adj_ng2(row, kk) = 1;
                        end
                    end
                end
            end

            % new adjacency matrix
            %adj_ng2

            % isequal(adj_ng, adj_ng2)

        end

    end


    % create dot file
    draw_dot(CL_ID, adj_ng, gr_ng_labels, basedir);

