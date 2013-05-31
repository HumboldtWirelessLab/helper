% MIN_DRATIO - min. delivery ratio to all 2-hop neighbors
function MPR = mpr_selection_greedy(H, curr_node, MIN_DRATIO)
    %
    debug = 1;
    MPR_MAX_PER = 20;
    ONE_HOP_TWO_HOP_MAX_PER = 50;
    % with new metric m1
    MPR = mpr_selection_m1(H*100, curr_node, MPR_MAX_PER, ONE_HOP_TWO_HOP_MAX_PER);

    disp(['Init MPR set ', int2str(size(MPR,2))]);
    
    ALLOW_RETRY = false;
    %MIN_DRATIO = 0.9;
    toterm = 0;
    while (1)
        % replace MPR selection algo by something where link quality is taken into
        % account
        MIN_PDR = (100 - ONE_HOP_TWO_HOP_MAX_PER) / 100;
        [oneHopR, twoHopR] = calc_mpr_coverage(H, curr_node, MPR, MIN_PDR);
        if (debug)
            oneHopR
            twoHopR
            %mean_oneHopR = mean(oneHopR(:,2))
            %mean_twoHopR = mean(twoHopR(:,2))
        end

        calced_pdr = [1 1; oneHopR; twoHopR];
        exp_dr = mean(calced_pdr(:,2));
        if (debug)
            disp(['Expected CA: ', num2str(exp_dr)]);
        end

        % greedy approach: search for the 2-hop neighbor with lowest coverage;
        % select an additional MPR to improve his coverage
        MPR_PLUS_MAX_PER = 80;
        twoHopRsorted = sortrows(twoHopR, 2);

        if (exp_dr > MIN_DRATIO)
           disp('min delivery ratio reached; finish.');
           break; 
        end

        found_sol = 0;
        for ii=1:size(twoHopRsorted,1)
            bad_node = twoHopRsorted(ii,1);
            bad_node_nbs = find(H(bad_node,:) >= MIN_PDR); 

            % 1-hop nbs not beeing MPRs
            OneHopNBs = find(H(curr_node,:) >= 1-MPR_PLUS_MAX_PER/100);
            if (~ALLOW_RETRY)
                OneHopNBs = setdiff(OneHopNBs, MPR);
            end
            if (isempty(OneHopNBs))
               continue;
            end
            % metric : DR from curr_node to this candidate \mult DR from candidate to bad node
            tmp = [OneHopNBs' (H(curr_node,OneHopNBs) .* H(OneHopNBs,bad_node)')'];
            tmp = sortrows(tmp, 2);
            cand_MPR = tmp(end,1); % choose the best
            MPR = [MPR cand_MPR];
            size(MPR,2)
            % solution found; break
            found_sol = 1;
            break;
        end
        if (found_sol == 0)
           % no solution found to improve coverage; break
           break;
        end
    end
end