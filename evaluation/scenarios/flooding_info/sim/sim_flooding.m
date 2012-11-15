clear;

seed = 102;
rand('twister', seed);
randn('state', seed);

%addpath(path,'./scheduling');

%addpath(path,'D:\Program Files\MATLAB\R2009b\toolbox\scheduling');
%addpath(path,'D:\Program Files\MATLAB\R2009b\toolbox\scheduling\stdemos');

fromfile = 1;
if (fromfile)
    load 'sim_flooding.mat'
    fromfile = 1;
end

gui = 1;
symmetric = 0; % make all links symmetric
max_seeds = 23;%10;
online = 0;
simflooding = 1;
simmpr_olsr = 1;

if (~fromfile)
    try
        if (online)
            xmldata = urlread('http://192.168.4.117/cgi-bin-brn/linkinfo.cgi');
            fid = fopen('linkstat.xml', 'w');
            fprintf(fid, '%s', xmldata);
            fclose(fid);
        end
        data = xml2struct('linkstat.xml');
    catch exc
       exc
       pause(30);
       continue;
    end

    disp('Loaded ...');

    entry = data.entries.entry;

    allrates = [2 12]; %[2 4 11 12 18 22 24 36 48 72 96 108];

    % ref to node names
    nodelst = cell(1,1);
    idx = 1;
    for node_i=1:size(entry,2)
       src = entry{node_i}.Attributes.from;
       if (idx == 1)
            nodelst{idx} = src;
            idx = idx + 1;
       else
           if (isempty(find(ismember(nodelst, src)==1)))
                nodelst{idx} = src;
                idx = idx + 1;
           end
       end
    end

    % adjacent matrix construction w/ delivery rate
    adj = cell(size(allrates,2), 1);
    for ii=1:size(adj,1)
       adj{ii} = zeros(size(nodelst,2), size(nodelst,2));
    end

    for node_i=1:size(entry,2)
       src = entry{node_i}.Attributes.from;
       src_idx = find(ismember(nodelst, src)==1);

       if (isfield(entry{node_i}, 'link'))
           for nb_i=1:size(entry{node_i}.link,2)
                lnks = [];
                if (size(entry{node_i}.link,2) == 1)
                    lnks = entry{node_i}.link;
                    dst = lnks.Attributes.to;
                else
                    lnks = entry{node_i}.link{nb_i};
                    dst = lnks.Attributes.to;
                end

                dst_idx = find(ismember(nodelst, dst)==1);

                if (size(lnks.link_info,2) == 1)
                        rate = str2num(lnks.link_info.Attributes.rate);
                        size_bytes = str2num(lnks.link_info.Attributes.size);
                        fwd = str2num(lnks.link_info.Attributes.fwd);
                        rev = str2num(lnks.link_info.Attributes.rev);

                        %disp(strcat(src, ' -> ', dst, ' ', fwd, '/', rev));

                        brate_idx = find(allrates == rate);
                        adj{brate_idx}(src_idx, dst_idx) = rev;
                else
                    for rates_i=1:size(lnks.link_info,2)
                        rate = str2num(lnks.link_info{rates_i}.Attributes.rate);
                        size_bytes = str2num(lnks.link_info{rates_i}.Attributes.size);
                        fwd = str2num(lnks.link_info{rates_i}.Attributes.fwd);
                        rev = str2num(lnks.link_info{rates_i}.Attributes.rev);

                        %disp(strcat(src, ' -> ', dst, ' ', fwd, '/', rev));
                        brate_idx = find(allrates == rate);
                        adj{brate_idx}(src_idx, dst_idx) = rev;
                    end
                end
           end
       end
    end
    save 'sim_flooding.mat'
end

% SIM FLOODING
if (simflooding)
    rerun_simf = 1;
    
    if (~rerun_simf)
        load 'sim_flooding_res.mat'
    else
        % play with each bitrate
        deliv_ratio_flood = zeros(size(allrates,2),size(adj{1},1));
        fwd_cnt_flood = zeros(size(allrates,2),size(adj{1},1));
        for s_i=1:max_seeds
            progress = s_i/max_seeds;
            if (gui)
                progressbar(progress);
            else
                progress
            end
            for ii=1:size(adj,1)
                H = adj{ii};

                % make H symmetric
                if (symmetric)
                    disp('Dirty symmetry');
                    for i=1:size(H,1)
                       for j=1:size(H,2)
                           H(i,j) = min(H(i,j), H(j,i));
                       end
                    end
                end
                % start flooding from each node
                for fl_i=1:size(H,1)
                    [dratio, fwd_cnt] = flood_forwarding(H, fl_i);
                    deliv_ratio_flood(ii, fl_i) = deliv_ratio_flood(ii, fl_i) + dratio;
                    fwd_cnt_flood(ii, fl_i) = fwd_cnt_flood(ii, fl_i) + fwd_cnt;
                end
            end
        end
        % average
        deliv_ratio_flood = deliv_ratio_flood / max_seeds;
        fwd_cnt_flood = fwd_cnt_flood / max_seeds;
        save 'sim_flooding_res.mat'
    end

    if (gui)
        str = cell(size(allrates,2),1);
        for lgi=1:size(allrates,2)
           str{lgi} = num2str(allrates(lgi)/2);
        end
        if (0)
           clmap = jet(size(deliv_ratio_flood,1));
           for ii=1:size(deliv_ratio_flood,1)
              [h,stats] = cdfplot(deliv_ratio_flood(ii,:));
              set(h,'LineWidth',2,'Color',clmap(ii,:));
              hold on;      
           end
           xlabel('Delivery Ratio'); 
           ylabel('F(%)');
           title('Flooding');
           legend(str,'Location','Best');
        else
            figure;
            boxplot(deliv_ratio_flood');
            grid on;
            xlabel('Bitrate (Mbps)');
            ylabel('Delivery Ratio');
            set(gca,'XTick',1:size(allrates,2));
            set(gca,'XTickLabel',str);     
            title('Flooding Performance im BRN');
            
            figure;
            boxplot(fwd_cnt_flood');
            grid on;
            xlabel('Bitrate (Mbps)');
            ylabel('Forwarder Count');
            set(gca,'XTick',1:size(allrates,2));
            set(gca,'XTickLabel',str);     
            title('Flooding Performance im BRN');
        end
    end
end

%%%%%%%%%%%
% SIM MPR algorithm; OLSR

if (simmpr_olsr)
   
   %MAX_PER = 10; % link abstraction
    % MIN_DRATIO - min. delivery ratio to all 2-hop neighbors
    MIN_DRATIO = 0.5;%0.9;
   
    % start MPR flooding from each node
    deliv_ratio_mpr = zeros(size(allrates,2),size(adj{1},1));
    fwd_cnt_mpr = zeros(size(allrates,2),size(adj{1},1));
    for s_i=1:max_seeds % seeds
        progress = s_i/max_seeds;
        if (gui)
            progressbar(progress);
        else
            progress
        end
        for ii=1:size(adj,1) % bitrates
           H = adj{ii};

           % make H symmetric
           if (symmetric)
                disp('Dirty symmetry');
                for i=1:size(H,1)
                   for j=1:size(H,2)
                       H(i,j) = min(H(i,j), H(j,i));
                   end
                end
           end
           %H(find(H>0)) = 100;

           % construct MPR set for each node; node_id is index
           MPRs = cell(size(H,1), 1);
           for i=1:size(H,1)
               % run MPR algo for each node
               i
               MAX_PER = (1-MIN_DRATIO)*100; % 0-100
               MPRs{i} = mpr_selection(H, i, MAX_PER);
               %MPRs{i} = mpr_selection_greedy(H/100, i, MIN_DRATIO);
           end
           % run MPR forwarding
           for fl_i=1:size(H,1)
                [dratio, fwd_cnt] = mpr_forwarding(H, MPRs, fl_i);
                deliv_ratio_mpr(ii, fl_i) = deliv_ratio_mpr(ii, fl_i) + dratio;
                % fwd_cnt
                fwd_cnt_mpr(ii, fl_i) = fwd_cnt_mpr(ii, fl_i) + fwd_cnt;
           end   
        end
    end
    % average
    deliv_ratio_mpr = deliv_ratio_mpr / max_seeds;
    fwd_cnt_mpr = fwd_cnt_mpr / max_seeds;
    
    if (gui)
        str = cell(size(allrates,2),1);
        for lgi=1:size(allrates,2)
           str{lgi} = num2str(allrates(lgi)/2);
        end
        figure;
        boxplot(deliv_ratio_mpr');
        grid on;
        xlabel('Bitrate (Mbps)');
        ylabel('Delivery Ratio');
        set(gca,'XTick',1:size(allrates,2));
        set(gca,'XTickLabel',str);     
        title('MPR Performance im BRN');

        figure;
        boxplot(fwd_cnt_mpr');
        grid on;
        xlabel('Bitrate (Mbps)');
        ylabel('Forwarder Count');
        set(gca,'XTick',1:size(allrates,2));
        set(gca,'XTickLabel',str);     
        title('MPR Performance im BRN');
    end    
end