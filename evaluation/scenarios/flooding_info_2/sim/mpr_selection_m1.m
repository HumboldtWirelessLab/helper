%
% MPR selection w/ heuristic m1: choose the node which covers the most
% nodes in expectation. Note: links are lossy
% MPR_MAX_PER - make sure that the link between me and the MPR is good enough
% 1HOP_2HOP_MAX_PER - connectivity between my 1-hop nbs and their 2 hop nbs
%
function MPR = mpr_selection_m1(H, curr_node, MPR_MAX_PER, ONE_HOP_TWO_HOP_MAX_PER)
   % 1-hop nbs
   OneHopNBs = find(H(curr_node,:) >= 100-MPR_MAX_PER); 
   % 2-hop nbs
   TwoHopNBs = [];
   for nb_i=1:size(OneHopNBs,2)
       curr_nb = OneHopNBs(nb_i);
       curr_nb_nbs = find(H(curr_nb,:) >= 100-ONE_HOP_TWO_HOP_MAX_PER); 
       % remove all 1-hop nbs
       TwoHopNBs = [TwoHopNBs setdiff(curr_nb_nbs, OneHopNBs)];
   end
   TwoHopNBs = unique(TwoHopNBs);
   TwoHopNBs = setdiff(TwoHopNBs, curr_node);
   %TwoHopNBs
   
   % MPR calculation
   MPR = [];
   % step 1: select those 1-hop nbs as MPRs which are the only nb of some
   % node in 2-hop nb
   for two_nb_i=1:size(TwoHopNBs,2)
       curr_tnb = TwoHopNBs(two_nb_i);
       curr_tnb_nbs = find(H(curr_tnb,:) >= 100-ONE_HOP_TWO_HOP_MAX_PER);
       iset = intersect(curr_tnb_nbs, OneHopNBs);
       if (size(iset,2) == 1)
          % MPR found
          MPR = [MPR iset];
       end
   end
   MPR = unique(MPR);
   %MPR
   % step 2: consider node whith max uncovered nodes as nbs
   while(1)
      uncovered_two_hop_nodes = TwoHopNBs;
      for mpr_i=1:size(MPR,2)
          curr_mpr = MPR(mpr_i);
          covered_nodes = find(H(curr_mpr,:) >= 100-ONE_HOP_TWO_HOP_MAX_PER);
          uncovered_two_hop_nodes = setdiff(uncovered_two_hop_nodes, covered_nodes);
      end
      if (isempty(uncovered_two_hop_nodes))
         break; 
      end
      
      % some nodes are uncovered
      best_node = [];
      max_metric = 0;
      for nb_i=1:size(OneHopNBs,2)
            curr_nb = OneHopNBs(nb_i);
            if (find(MPR == curr_nb)) % already included
                continue;
            end
            curr_nb_nbs = find(H(curr_nb,:) >= 100-ONE_HOP_TWO_HOP_MAX_PER);
            curr_nb_nbs = intersect(curr_nb_nbs, uncovered_two_hop_nodes); % uncovered nodes covered by this node
            % new calc sum delivery rate over all neighbors
            metric = sum(H(curr_nb, curr_nb_nbs));
            if (metric > max_metric)
                max_metric = metric;
                best_node = curr_nb;
            end
      end
      
      % add best to MPR
      MPR = [MPR best_node];
   end
   %size(MPR,2)
end