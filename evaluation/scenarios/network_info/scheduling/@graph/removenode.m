function g = removenode(g,listOfNodes)  
%REMOVENODE  Removes ordered node or nodes.
%
%    graph = REMOVENODE(graph,listOfNodes)
%      graph        - object graph
%      listOfNodes  - number (or array of numbers) of node to removal
%           listOfNodes = 2;
%           listOfNodes = [2 3 4];
%           listOfNodes = 2:4;
%
%  See also GRAPH, NODE.

%   Author(s): V. Navratil
%   Copyright (c) 2005 CTU FEE
%   $Revision: 674 $  $Date: 2007-03-02 09:34:43 +0100 (pá, 02 III 2007) $

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


    nodes = g.N;
    eps = g.eps;
    edges = g.E;

    if length(nodes) >= max(listOfNodes)
        
        edgesToDelete = [];
        for i = 1:length(listOfNodes)
            init = find(eps(:,1) == listOfNodes(i));
            final = find(eps(:,2) == listOfNodes(i));
            edgesToDelete = [edgesToDelete init' final'];
        end

        listOfNodesTmp = listOfNodes;
        for i = 1:length(listOfNodes)
            index = find(eps(:) > listOfNodesTmp(i));
            eps(index) = eps(index) - 1;
            listOfNodesTmp = listOfNodesTmp - 1;
        end
        
        eps(edgesToDelete,:) = [];
        edges(edgesToDelete) = [];
        nodes(listOfNodes) = [];
        
    else
        error('TORSCHE:graph:tooManyNodes', ['There are ' num2str(numNodes) ' nodes in the graph.']);
        return;
    end

    g.N = nodes;
    g.E = edges;
    g.eps = eps;


%end .. @graph/removenode
    