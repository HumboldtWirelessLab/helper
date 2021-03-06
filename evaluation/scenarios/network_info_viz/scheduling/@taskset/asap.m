function out=asap(taskset, varargin)
%ASAP computes ASAP(As Soon As Posible) for taskset
%
%Synopsis
%        Tout = ASAP(T [,m])
% asap_vector = ASAP(T, 'asap') 
%
%Description
% Tout = ASAP(T [,m]) computes ASAP for all tasks in taskset T.
% Properties:
%  T:
%    - set of tasks
%  m:
%    - number of processors
%  Tout:
%    - set of tasks with asap
%
% asap_vector = ASAP(T, 'asap') returns asap vector from taskset.
% Properties:
%  T:
%    - set of tasks
%  asap_vector:
%    - asap vector
%     
%  See also TASKSET/ALAP.

%   Author(s): M. Kutil
%   Copyright (c) 2005 CTU FEE
%   $Revision: 1750 $  $Date: 2007-09-20 11:07:47 +0200 (čt, 20 IX 2007) $

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

% output vector
if nargin>1
    if strcmpi(varargin{1},'asap')
        for i = 1:count(taskset)
            str = struct(taskset.tasks{i});
            if isempty(str.ASAP)
                out(i) = nan;
            else
                out(i) = str.ASAP;
            end
        end
        return
    end
end

% computing vector
g = graph('adj',[[taskset.Prec; ones(1,size(taskset))], zeros(size(taskset)+1,1)]); % ones(... virtual node for release time accepting
for i = 1 : size(taskset)
    to=find(taskset.Prec(i,:));
    for ii = 1 : length(to)
        g.E(between(g,i,to(ii))).UserParam = -taskset.tasks{i}.ProcTime;
    end
    % add time for virtual node
    g.E(between(g,size(taskset)+1,i)).UserParam = -taskset.tasks{i}.ReleaseTime;    
end

proctime = [get(taskset,'ProcTime') 0]; % 0 - for virtual node
for i = 1 : count(taskset)
    % Critical path
    if length(pred(g,i)) > 0
        g_pred = subgraph(g,[pred(g,i) i]);
        [U,P,M]=floyd(g_pred);     
        cp = -min(U(:,end)); %cp = critical path
    else
        cp = 0;
    end
    
    % resourse bound
    resbound = 0;
    if nargin == 2
        K = varargin{1};
        prede = pred(g,i);
        resbound = sum(floor(proctime(prede)./K));
    end

    asap = max(cp, resbound);
    taskset.tasks{i} = set_helper(taskset.tasks{i},'ASAP',asap);
end
out = taskset;
%end .. @taskset/asap
