function g = removeedge(g,listOfEdges)
%REMOVEEDGE  Removes ordered edge or edges.
%
%    graph = REMOVEEDGE(graph,listOfEdges)
%      graph        - object graph
%      listOfEdges  - number (or array of numbers) of edge to removal
%           listOfEdges = 2;
%           listOfEdges = [2 3 4];
%           listOfEdges = [2:4];
%
%  See also GRAPH, EDGE.

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


    numEdges = length(g.E);
    if numEdges >= max(listOfEdges)
        g.E(listOfEdges) = [];
        g.eps(listOfEdges,:) = [];
    else
        error('TORSCHE:graph:tooManyEdges', ['There are ' num2str(numEdges) ' edges in the graph.']);
        return;
    end
    

    
%end .. @graph/removeedge
