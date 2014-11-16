function out=alap(taskset, varargin)
%ALAP compute ALAP(As Late As Posible) for taskset
%
%Synopsis
%        Tout = ALAP(T, UB, [m])
% alap_vector = ALAP(T, 'alap')
%
%Description
% Tout=ALAP(T, UB, [m]) computes ALAP for all tasks in taskset T.
% Properties:
%  T:
%    - set of tasks
%  UB:
%    - upper bound
%  m:
%    - number of processors
%  Tout:
%    - set of tasks with alap
%
% alap_vector = ALAP(T, 'alap') returns alap vector from taskset.
% Properties:
%  T:
%    - set of tasks
%  alap_vector:
%    - alap vector
%     
% ALAP for each task is stored into set of task, the biggest ALAP is
% returned.
%
% See also TASKSET/ASAP.

%   Author(s): M. Kutil
%   Copyright (c) 2004 CTU FEE
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
    if strcmpi(varargin{1},'alap')
        for i = 1:count(taskset)
            str = struct(taskset.tasks{i});
            if isempty(str.ALAP)
                out(i) = nan;
            else
                out(i) = str.ALAP;
            end
        end
        return
    end
end

% computing vector
if nargin>1
    UB = varargin{1};
else
    error('Input argument "UB" is undefined.');
end

g = graph('adj',[taskset.Prec, ones(size(taskset),1);zeros(1,size(taskset)+1)]); % ones(... virtual node for last task
for i = 1 : size(taskset)
    to=find(taskset.Prec(i,:));
    for ii = 1 : length(to)
        g.E(between(g,i,to(ii))).UserParam = -taskset.tasks{i}.ProcTime;
    end
    % add time for virtual node
    g.E(between(g,i,size(taskset)+1)).UserParam = -taskset.tasks{i}.ProcTime;
end

proctime = [get_vprop(taskset, 'ProcTime') 0]; 
for i = 1 : count(taskset)
    % critical path
    if ~isempty(succ(g,i))
        g_succ = subgraph(g,[i succ(g,i)]);
        [U,P,M]=floyd(g_succ);
        cp = -min(U(1,:)); %cp = critical path
    else
        cp = 0;
    end
    % resourse bound
    resbound = 0;
    if nargin == 3
        K = varargin{2};
        succe = succ(g,i);
        resbound = sum(floor(proctime(succe)./K)) + taskset.tasks{i}.ProcTime;
    end
    
    alap = UB - max(cp,resbound);
    if alap<0
        warning('ALAP is less than 0!')
    end
    task_struct = struct(taskset.tasks{i});
    if alap<task_struct.ASAP
        error('scheduling:alap','ALAP is less than ASAP!')
    end    
    taskset.tasks{i} = set_helper(taskset.tasks{i},'ALAP',alap);
end
out = taskset;
%end .. @taskset/alap
