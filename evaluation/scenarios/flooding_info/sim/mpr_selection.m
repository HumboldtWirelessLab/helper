%
% H - link table
% curr_node - current forwarder
% MAX_PER - link abstraction, PER between 0 and 100
%
function MPR = mpr_selection(H, curr_node, MAX_PER)
   % 1-hop nbs
   OneHopNBs = find(H(curr_node,:) >= 100-MAX_PER); 
   % 2-hop nbs
   TwoHopNBs = [];
   for nb_i=1:size(OneHopNBs,2)
       curr_nb = OneHopNBs(nb_i);
       curr_nb_nbs = find(H(curr_nb,:) >= 100-MAX_PER); 
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
       curr_tnb_nbs = find(H(curr_tnb,:) >= 100-MAX_PER);
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
          covered_nodes = find(H(curr_mpr,:) >= 100-MAX_PER);
          uncovered_two_hop_nodes = setdiff(uncovered_two_hop_nodes, covered_nodes);
      end
      if (isempty(uncovered_two_hop_nodes))
         break; 
      end
      
      % some nodes are uncovered
      best_node = [];
      max_covered = 0;
      for nb_i=1:size(OneHopNBs,2)
            curr_nb = OneHopNBs(nb_i);
            if (find(MPR == curr_nb)) % already included
                continue;
            end
            curr_nb_nbs = find(H(curr_nb,:) >= 100-MAX_PER);
            curr_nb_nbs = intersect(curr_nb_nbs, uncovered_two_hop_nodes); % uncovered nodes covered by this node
            if (size(curr_nb_nbs,2) > max_covered)
                max_covered = size(curr_nb_nbs,2);
                best_node = curr_nb;
            end
      end
      
      % add best to MPR
      MPR = [MPR best_node];
   end
   %size(MPR,2)
end