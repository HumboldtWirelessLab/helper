% SPANNNINGTREE_DEMO Demo application of the graph coloring
%
%    See also SPANNNINGTREE

%   Author(s): R.Capek, V. Navratil, P.Sucha
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
disp('Spanning tree demo (greedy algorithm).');
disp('------------------------------------------------------');


%create graph
disp(' ');
disp('Adjacency matrix of the input graph');
A = [inf  1   2  inf  7;...
     inf inf  3   4  inf;...
     inf  9  inf  1   1;...
      8   5  inf inf inf;...
      7  inf  4   5  inf]
g1 = graph(A);
g1.Name = 'Input Graph';

%call the algorithm
g2 = spanningtree(g1);
g2.Name = 'Spanning Tree';

%display results
graphedit(g1,g2);


