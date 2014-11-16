function distance = dijkstra(g,startNode,varargin)
%DIJKSTRA finds the shortest path between reference node and other nodes in
%graph.
%
% Synopsis
%   DISTANCE = DIJKSTRA(GRAPH,STARTNODE,USERPARAMPOSITION)
%
% Description
%  Parameters:
%    GRAPH:
%      - graph with cost betweens nodes
%      - type inf when edge between two edges does not exist
%    STARTNODE:
%      - reference node
%    USERPARAMPOSITION:
%      - position in UserParam of Nodes where number representative color
%        is saved. This parameter is optional. Default is 1. 
%    DISTANCE:
%      - list of distances between reference node and other nodes 
%
% See also GRAPH/GRAPH, GRAPH/FLOYD, GRAPH/CRITICALCIRCUITRATIO

%   Author(s): R. Prikner, P. Sucha
%   Copyright (c) 2006 CTU FEE
%   $Revision: 1896 $  $Date: 2007-10-12 08:13:54 +0200 (pá, 12 X 2007) $

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

    if nargin > 2
        userParamPosition = varargin{1};
    else
        userParamPosition = 1;
    end

matrix = edge2param(g,userParamPosition);
n = size(matrix,1);

visited(1:n) = 0;

distance(1:n) = inf;

distance(startNode) = 0;

for a = 1:(n-1)
    
    %read no visited node
    no_visited = [];
    for b = 1:n
         if visited(b) == 0 
             no_visited = [no_visited distance(b)];
         else
             no_visited = [no_visited inf];
         end
             
     end;
    
     %selection of min
     [x,y] = min(no_visited);
    
     %mark visited node
     visited(y) = 1;
     
     if(x==inf)
         break
     end;
     
     %expand and update last visited node
     for v = 1:n,          
         if ( ( matrix(y, v) + distance(y)) < distance(v) )
             distance(v) = distance(y) + matrix(y, v);                                    
         end;
     end;    
end;

return

