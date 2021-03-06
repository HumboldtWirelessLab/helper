function matrix=adj(G)
%ADJ   Return adjacency matrix of graph
%
% Syntax
%    matrix = ADJ(G)
%     matrix - adjacency matrix
%     G      - graph

%   Author(s):  M. Kutil
%   Copyright (c) 2004 CTU FEE
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


[numEdges,x] = size(G.eps);
matrix = zeros(length(G.N));
for i = 1:numEdges
    matrix(G.eps(i,1),G.eps(i,2)) = matrix(G.eps(i,1),G.eps(i,2)) + 1;
end

%end .. @graph/adj
