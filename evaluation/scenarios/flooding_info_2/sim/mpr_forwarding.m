function [dratio, fwd_cnt] = mpr_forwarding(H, MPRs, src)
    %%%%%
    % Simulate flooding
    open = [src];
    closed = [];
    fwd_cnt = 0;

    while(~isempty(open))
       % choose random node from open
       rnd_open = randint(1,1,size(open,1))+1;
       choose_node = open(rnd_open);
       fwd_cnt = fwd_cnt + 1;
       % update open & closed
       open(rnd_open) = [];
       closed = [closed; choose_node]; 

       % simulate transmission for each nb
       nbs = H(choose_node,:);
       for nb_i=1:size(nbs,2)

          % bernoulli trial
          nb_pdr = nbs(nb_i);
          rnd_tx = randint(1,1,100);
          if (rnd_tx < nb_pdr)
             % successful transmission;
             
             % decide on forwarding
             if (find(closed == nb_i))
                 % already forwarded
                 continue;
             end
             % check if MPR
             prev_hop_mprs = MPRs(choose_node);
             if (isempty(find(prev_hop_mprs{1} == nb_i)))
                 % only MPR are forwarding messages
                 closed = [closed; nb_i];
                 continue;
             end
             % MPR and not already forwarded
             open = [open; nb_i];
          end
       end
    end
    
    dratio = (size(unique(closed),1) / size(H,1));
    if (dratio < 1)
       %setdiff(1:size(H,1), closed)
%       disp('missing nodes');
    end
end