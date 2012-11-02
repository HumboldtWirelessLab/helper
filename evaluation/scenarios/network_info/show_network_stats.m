function show_network_stats(graphfile, basedir)

%clear;

disp('Loading ...');
gr = load(graphfile);

% test only
% testCL = [2,3,4,5,6,7,8,10,12,13,14,15,16,17,18,21,22,23,24,25,26,29,31,32,33,34,35,37,38,39,40,41,42,43,44,45,46,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67];
% gr = gr(testCL,testCL);

% PHY stuff
bitrate = 1;
txpower = 19;
rfchannel = 1;

% Plot params
show_lnk_asym = 1;
show_ng = 1;
show_sp = 1;
show_mcg = 1;

addpath(path,'./scheduling');
addpath(path,'./graphviz');

% ref to node names
nodelst = cell(1,1);
idx = 1;
for node_i=1:size(gr,1)
    nodelst{node_i} = node_i;
end

%
% Link Asymmetry
%
if (show_lnk_asym)

    f = figure('Position',[200 200 1200 450]);

    adj = gr; % PDR from 0 to 100
    metric_asyms = [];
    for ii=1:size(adj,1) % for each node
        idx = find(adj(ii,:) > 0);
        m_asym = abs(adj(idx,ii) - adj(ii,idx)');
        metric_asyms = [metric_asyms; m_asym];
    end

    %hist(node_deg, 1:max(node_deg));
    %grid on;
    %title(['Histogram of Node Degree, PSR-THR=', int2str(thr)]);
    %xlabel('Node Degree');
    %ylabel('# Occurence');

    [h,stats] = cdfplot(metric_asyms);
    set(h,'LineWidth',2);
    grid on;
    title(['CDFPlot of Link Asymmetry']);
    xlabel('Link Asymmetry (abs(PDRfwd - PDRrev))');
    ylabel('CDF of links');
end

%
% Node degree
%    
if (show_ng)

    f = figure('Position',[200 200 1200 450]);

    adj = gr;% * 100; % PDR from 0 to 100
    succv = [90 50 10];
    for succ_i=1:size(succv,2)
        subplot(1,3,succ_i);

        thr = succv(succ_i);

        node_degs = zeros(size(adj,1),1);
        for ii=1:size(adj,1)
            node_deg(ii) = size(find(adj(ii,:) > thr),2);
        end

        %hist(node_deg, 1:max(node_deg));
        %grid on;
        %title(['Histogram of Node Degree, PSR-THR=', int2str(thr)]);
        %xlabel('Node Degree');
        %ylabel('# Occurence');

        [h,stats] = cdfplot(node_deg);
        set(h,'LineWidth',2);
        grid on;
        title(['CDFPlot of Node Degree, PSR-THR=', int2str(thr)]);
        xlabel('Node Degree');
        ylabel('CDF of nodes');
    end
end

%
% Shortest Path
%
if (show_sp)

    f = figure('Position',[200 200 1200 450]);
    adj = gr; %* 100; % PDR from 0 to 100

    %
    % consider ETX metric
    %
   for ri=1:size(adj,1)
      for ci=ri+1:size(adj,2)
         x = 1/(adj(ri,ci)/100); 
         y = 1/(adj(ci,ri)/100);
         if (x == 0 || y == 0)
            etx_v = Inf; 
         else
            etx_v = 100*(x*y);
         end
         if (etx_v < 100)
             x
             y
             etx_v
         end
         assert(etx_v >= 100);
         adj(ri,ci) = etx_v;
         adj(ci,ri) = etx_v;
      end
   end

   num_nodes = size(nodelst,2);

   k = 1;
   route_lens = [];
   for src=1:num_nodes
      for dst=src+1:num_nodes
           %------Call kShortestPath------:
           [shortestPaths, totalCosts] = kShortestPath(adj, src, dst, k);
           if (~isempty(shortestPaths))
               route_len = size(shortestPaths{1},2) - 1;
               route_lens = [route_lens route_len];
           end
      end
   end

   if (~isempty(route_lens))
        subplot(1,2,1);
        [h,stats] = cdfplot(route_lens);
        set(h,'LineWidth',2);
        grid on;
        title(['CDFPlot of Route Length (ETX), #nodes=', int2str(size(nodelst,2))]);
        xlabel('Route Length (no. of hops)');

        subplot(1,2,2);
        hist(route_lens, 1:max(route_lens));
        grid on;
        title(['Histogram of Route Length (ETX), #nodes=', int2str(size(nodelst,2))]);
        xlabel('Route Length (no. of hops)');
        ylabel('# Occurence');
   end
end

%
% Maximum connected component
%    
if (show_mcg)

    f = figure('Position',[200 200 1200 450]);

    adj = gr;% * 100; % PDR from 0 to 100
%   succv = [90 10 50];
    succv = [50];
    for succ_i=1:size(succv,2)
        subplot(1,size(succv,2),succ_i);
        disp('*****************');
        %cmap = colormap(lines);
        jj = 1;

        s.connected_graphs.connected_graph{succ_i}.Attributes.min_pdr = succv(succ_i);
        bdata = [];
        mygr = adj;
        mygr(mygr < succv(succ_i)) = 0;

        if (max(max(mygr)) > 0)
           %mygrsp = sparse(mygr);
           %[S,C] = graphconncomp(mygrsp);
           g = graph('adj',mygr);
           C = tarjan(g);

           s.connected_graphs.connected_graph{succ_i}.clusters.Attributes.bitrate = bitrate;
           s.connected_graphs.connected_graph{succ_i}.clusters.Attributes.number = max(C);
           for kk=1:max(C)
              bdata(jj,kk) = size(find(C==kk),2);
              cluster_nodes = nodelst(find(C==kk));
              s.connected_graphs.connected_graph{succ_i}.clusters.cluster{kk}.Attributes.id = kk;
              s.connected_graphs.connected_graph{succ_i}.clusters.cluster{kk}.Attributes.size = size(find(C==kk),2);
              cl_nodes = [];
              for pp=1:size(cluster_nodes,2)
                s.connected_graphs.connected_graph{succ_i}.clusters.cluster{kk}.node{pp}.Text = cluster_nodes{pp};
                cl_nodes = [cl_nodes cluster_nodes{pp}];
              end
              disp(['SR=', int2str(succv(succ_i)), ',C=', int2str(kk), ',N=[', int2str(cl_nodes), ']']);
              % run dot to generate network graph for each cluster

              %cl_nodes = [2,3,4,5,6,7,8,10,12,13,14,15,16,17,18,21,22,23,24,25,26,29,31,32,33,34,35,37,38,39,40,41,42,43,44,45,46,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67];
              grTmp = gr(cl_nodes,cl_nodes);
              grTmp(grTmp < succv(succ_i)) = 0;
              grTmp(grTmp >= succv(succ_i)) = 1;
              pretty_graph(kk, grTmp);
              system(['dot -Tps _GtDout', int2str(kk), '.dot -o ',basedir,'/CL', int2str(kk), '.ps']);
           end
           jj = jj + 1;
        end

        bdatas = zeros(size(bdata,2), size(bdata,1));
        for kk=1:size(bdata,1)
           bdatas(:,kk) = sortrows(bdata(kk,:)');
        end

        bar(fliplr(bdatas'),'stack');
        grid on;
        title(strcat('Connected Comp. Size (SR>', int2str(succv(succ_i)),'%)'), 'FontSize',9);
        xlabel('#Cluster');
        ylabel('Nodes');
        %set(gca,'XTickLabel',str);
    end
end

end
