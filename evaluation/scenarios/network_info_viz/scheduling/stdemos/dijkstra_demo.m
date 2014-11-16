% DIJKSTRA_DEMO Demo application of the longest paths
%
%    See also DIJKSTRA

%   Author(s): R.Capek, P.Sucha
%   Copyright (c) 2007 CTU FEE
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

clc;
disp('Demo of shortest paths (Dijkstra''s algorithm).');
disp('------------------------------------------------------');


%create graph
disp(' ');
disp('Adjacency matrix of the input graph');
A = [0   1   2   inf 7;
     inf 0   3   4   inf;
     inf 9   0   1   1;
     8   5   inf 0   inf;
     7   inf 4   5   0  ]
g = graph(A);
g.Name = 'G_{1}';

graphedit(g);

%define reference node
ref = 2;

%call algorithm
distance = dijkstra(g, ref);

%display results
disp(' ');
disp('Results:');
for i = 1:size(A,1);
    display(['Minimal distance from node ' int2str(ref) ' to node ' int2str(i) ' is ' int2str(distance(i)) '.']);
end

