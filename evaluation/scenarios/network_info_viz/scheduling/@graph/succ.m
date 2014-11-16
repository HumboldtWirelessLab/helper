function succ=succ(G,node)
%SUCC   Return all succecessors of node from graph
%
% Syntax
%    succ = SUCC(G,node)
%     node - node for which are computed succecessors
%     G    - graph
%     succ - succecessors

%   Author(s):  M. Kutil
%   Copyright (c) 2004 CTU FEE
%   $Revision: 182 $  $Date: 2005-07-25 20:44:46 +0200 (po, 25 VII 2005) $

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

adj_var = adj(G);
succ = zeros(1,length(adj_var));
adj_tmp = adj_var;
while sum(sum(adj_tmp))
    succ(find(adj_tmp(node,:)))=1;
    adj_tmp = sign(adj_tmp*adj_var);
end
succ=find(succ);
%end .. @graph/succ
