function [struct] = sat_prepare_clause (T, K)
%SAT_PREPARE_CLAUSE pripravy vystup pro vyrobu CNF klausuli
%
%    struct = SAT_PREPARE_CLAUSE(T, K) 
%      T      - set of task
%      K      - number of procesors
%      struct - struct with informations for sat schedulers

%   Author(s): M. Kutil
%   Copyright (c) 2004 CTU FEE
%   $Revision: 1543 $  $Date: 2007-09-18 09:51:46 +0200 (út, 18 IX 2007) $

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

struct.count = T.count; % task's number
struct.K = K; % procesors
struct.ProcTime = T.ProcTime;
struct.asap = asap(T,'asap');
struct.alap = alap(T,'alap');

% Edges
fprintf('Edges preparing: ');
[u,v]=find(T.Prec);
for edge=1:length(u)
    struct.edges(edge,:) = [u(edge) v(edge)];
end
fprintf('done.\n');

% no-family
fprintf('No-family preparing: ');
g = graph('adj',T.Prec);
nevrodine=[];
for v = 1:size(T)
    fprintf('.');
    task_v=T.tasks(v);
    pocetnevrodine = 0;
    for u=1:size(T)
        task_u=T.tasks(u);            
        if sum([pred(g,v) v succ(g,v)] == u)==0 % sloucit s predchozim forem dohromady              
            pocetnevrodine = pocetnevrodine +1;
            nevrodine(pocetnevrodine) = u;
        end
    end
    struct.nofam{v}=nevrodine(1:pocetnevrodine);
end
fprintf('done\n')
% end .. sat/sat_prepare_clause
