function pred=pred(G,node)
%PRED   Return all predecessors of node from graph
%
% Syntax
%    pred = PRED(G,node)
%     node - node for which are computed predecessors
%     G    - graph
%     pred - predecessors

%   Author(s):  M. Kutil
%   Copyright (c) 2004 CTU FEE
%   $Revision: 161 $  $Date: 2005-06-29 19:02:38 +0200 (st, 29 VI 2005) $

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
pred = zeros(1,length(v_adj));
adj_tmp = v_adj;
while sum(sum(adj_tmp))
    pred(find(adj_tmp(:,node)))=1;
    adj_tmp = sign(adj_tmp*v_adj);
end
pred=find(pred);
%end .. @graph/pred
