function [oneHopR, twoHopR] = calc_mpr_coverage(H, curr_node, curr_node_1h_nbs, MIN_PDR)

    if (size(curr_node_1h_nbs,2) > 7)
       disp('Warning large candidate set.'); 
    end

    nodes = size(H,1);
    % all 1-hop neighbors not selected as MPR
    curr_node_1h_nbs_other = setdiff(find(H(curr_node,:) > 0), curr_node_1h_nbs);

    % 2-hop nbs
    curr_node_2h_nbs = [];
    for nb_i=1:size(curr_node_1h_nbs,2)
       curr_nb = curr_node_1h_nbs(nb_i);
       curr_nb_nbs = find(H(curr_nb,:) >= MIN_PDR); 
       % remove all 1-hop nbs
       curr_node_2h_nbs = [curr_node_2h_nbs setdiff(curr_nb_nbs, curr_node_1h_nbs)];
    end
    curr_node_2h_nbs = unique(curr_node_2h_nbs);
    curr_node_2h_nbs = setdiff(curr_node_2h_nbs, curr_node);

    tmp = repmat(curr_node_1h_nbs,2,1);
    tmp(2,:) = tmp(2,:) * (-1);

    switch (size(curr_node_1h_nbs,2))
        case 1
            combs = combinations(tmp(:,1));
        case 2
            combs = combinations(tmp(:,1), tmp(:,2));
        case 3
            combs = combinations(tmp(:,1), tmp(:,2), tmp(:,3));
        case 4
            combs = combinations(tmp(:,1), tmp(:,2), tmp(:,3), tmp(:,4));
        case 5
            combs = combinations(tmp(:,1), tmp(:,2), tmp(:,3), tmp(:,4), tmp(:,5));
        case 6
            combs = combinations(tmp(:,1), tmp(:,2), tmp(:,3), tmp(:,4), tmp(:,5), tmp(:,6));
        case 7
            combs = combinations(tmp(:,1), tmp(:,2), tmp(:,3), tmp(:,4), tmp(:,5), tmp(:,6), tmp(:,7));
        case 8
            combs = combinations(tmp(:,1), tmp(:,2), tmp(:,3), tmp(:,4), tmp(:,5), tmp(:,6), tmp(:,7), tmp(:,8));
        case 9
            combs = combinations(tmp(:,1), tmp(:,2), tmp(:,3), tmp(:,4), tmp(:,5), tmp(:,6), tmp(:,7), tmp(:,8), tmp(:,9));
        case 10
            combs = combinations(tmp(:,1), tmp(:,2), tmp(:,3), tmp(:,4), tmp(:,5), tmp(:,6), tmp(:,7), tmp(:,8), tmp(:,9), tmp(:,10));
        otherwise
            disp(['Not yet implemented for', int2str(size(curr_node_1h_nbs,2)), ' !!!']);
            return;
    end

    % create transition matrix
    % curr_node combinations-lst 2hop_nbs
    T_sz = size(H,1) + size(combs,1) + size(H,1); %size(curr_node_1h_nbs,2);
    T = zeros(T_sz, T_sz);

    for ii=1:size(combs,1)
       row = combs(ii,:);
       p_succ = 1;
       row_nbs = [];
       for jj=1:size(row,2)
           if (row(jj) > 0)
              p_tmp = H(curr_node, row(jj));
              % node row(jj) received packet successfully
              row_jj_nbs = find(H(row(jj),:) > 0);
              row_jj_nbs = setdiff(row_jj_nbs, curr_node);
              row_jj_nbs = setdiff(row_jj_nbs, curr_node_1h_nbs);
              row_nbs{jj} = row_jj_nbs;
           else
              p_tmp = 1-H(curr_node, -row(jj));
           end
           p_succ = p_succ * p_tmp;
       end
       %p_succ
       T(curr_node,ii+nodes) = p_succ;
       % update 2 hop reachability
       for jj=1:size(curr_node_2h_nbs,2)
          curr_nb = curr_node_2h_nbs(jj);
          trans_prop = 1;
          for kk=1:size(row_nbs,2)
             tmp = row_nbs{kk}; 
             if (~isempty(find(tmp == curr_nb)))
                % found
                trans_prop = trans_prop * (1 - H(row(kk),curr_nb));
             end
          end
          if (find(curr_node_1h_nbs_other == curr_nb))
              % can be reached by curr_node directly
              trans_prop = trans_prop * (1 - H(curr_node,curr_nb));
          end
          trans_prop = 1 - trans_prop;
          T(ii+nodes,curr_nb) = trans_prop;
       end

       % update 1 hop reachability
       for jj=1:size(curr_node_1h_nbs,2)
          curr_nb = curr_node_1h_nbs(jj);
          trans_prop = 1;
          for kk=1:size(curr_node_1h_nbs,2)
             if (curr_nb == curr_node_1h_nbs(kk))
                 continue;
             end
             % found
             trans_prop = trans_prop * (1 - H(curr_node_1h_nbs(kk),curr_nb));
          end
          % can be reached by curr_node directly
          trans_prop = trans_prop * (1 - H(curr_node,curr_nb));

          trans_prop = 1 - trans_prop;
          T(ii+nodes,curr_nb + nodes + size(combs,1) - 1) = trans_prop;
          T(curr_nb + nodes + size(combs,1) - 1, curr_nb + nodes + size(combs,1) - 1) = 1; % test this!!!!!
       end   
    end

    % final states
    for ii=1:nodes
       if (curr_node == ii)
           continue;
       end
       if (find(curr_node_1h_nbs == ii))
           continue;
       end
       T(ii,ii) = 1;
    end
    %T(4,4) = 1;
    %...

    % this is strange????
    for jj=1:size(curr_node_1h_nbs,2)
        T(end-jj+1,end-jj+1) = 1;
        %T(end-curr_node_1h_nbs(jj)+1,end-curr_node_1h_nbs(jj)+1) = 1;
    end

    S = zeros(T_sz, 1)';
    S(curr_node) = 1;

    i = 1;
    max_i = 23;
    while (~isequal(T^i,T^(i+1)))
        i = i + 1;
        if (i > max_i)
            disp('Warning; not correct behavior!!!');
            break;
        end
    end

    T2 = S * (T^i);
    %T2

    oneHopR = zeros(size(curr_node_1h_nbs,2),2);
    for ii=1:size(curr_node_1h_nbs,2)
        oneHopR(ii,:) = [curr_node_1h_nbs(ii) T2(nodes+size(combs,1)+curr_node_1h_nbs(ii)-1)];
    end
    %oneHopR

    twoHopR = zeros(size(curr_node_2h_nbs,2),2);
    for ii=1:size(curr_node_2h_nbs,2)
        twoHopR(ii,:) = [curr_node_2h_nbs(ii) T2(curr_node_2h_nbs(ii))];
    end
    %twoHopR
end