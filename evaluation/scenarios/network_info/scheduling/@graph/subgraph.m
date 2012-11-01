function subgraph=subgraph(G,nodes)
%SUBGRAPH   Return subgraph of graph G, which includes nodes 'nodes'
%
% Syntax
%    subgraph = SUBGRAPH(G,nodes)
%     nodes    - nodes in new graph
%     G        - graph
%     subgraph - subgraph of graph G

%   Author(s):  M. Kutil
%   Copyright (c) 2004 CTU FEE
%   $Revision: 1542 $  $Date: 2007-09-18 09:47:44 +0200 (út, 18 IX 2007) $

% This file is part of Scheduling Toolbox.
% 
% Scheduling Toolbox is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 2 of the
% License, or (at your option) any later version.
% 
% Scheduling Toolbox is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with Scheduling Toolbox; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
% USA

v_adj = adj(G);
adj_new = v_adj(nodes, nodes);
subgraph = graph('adj',adj_new);

% move nodes
for i = 1 : length (nodes)
    subgraph.N(i) = G.N(nodes(i));
end
[x,y]=find(adj_new);
for i = 1 : length(x);
    edge = between(G,nodes(x(i)),nodes(y(i)));
    edge_new=between(subgraph,x(i),y(i));
    edge = G.E(edge);
    if iscell(edge) 
        edge=edge{1};
    end
    subgraph.E(edge_new) = edge;
end 
%end .. @graph/subgraph
