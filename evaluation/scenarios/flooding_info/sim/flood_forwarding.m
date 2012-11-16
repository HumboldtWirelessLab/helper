    function [dratio, fwd_cnt] = flood_forwarding(H, src)
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
             % successful transmission; add nb_i to open
             if (find(open == nb_i))
                 % already marked for forwarded
                 continue;
             end
             if (find(closed == nb_i))
                 % already forwarded
                 continue;
             end
             open = [open; nb_i];
          end
       end
    end
    dratio = (size(unique(closed),1) / size(H,1));
end