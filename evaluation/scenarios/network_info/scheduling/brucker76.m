function [taskset] = brucker76(taskset, prob, m)
%BRUCKER76 Brucker's scheduling algorithm
%
% Synopsis
%    TS = Brucker76(T, PROB, M)
%
% Description
%    TS = Brucker76(T, PROB, M) returns optimal schedule of problem
%    P|in-tree,pj=1|Lmax defined in object PROB.
%      Parameters:
%       T:
%         - input taskset
%       PROB:
%         - problem
%       M:
%         - number of processors
%
%    See also PROBLEM/PROBLEM, TASKSET/TASKSET, LISTSCH, HU.

%   Author(s): M. Stibor, M. Kutil
%   Copyright (c) 2005 CTU FEE
%   $Revision: 1768 $  $Date: 2007-09-20 15:27:36 +0200 (čt, 20 IX 2007) $

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


if ~(is(prob,'alpha','P') && is(prob,'betha','in-tree,pj=1') && is(prob,'gamma','Lmax'))
    error('This problem can''t be solved by Brucker76.');
end

% Inicialization
DueSave=taskset.duedate; % save DueDates for correction later

% Brucker76
root=find(sum(taskset.prec,2)==0); %find roots - root hasn't successors
taskset.DueDate(root) = 1 - taskset.DueDate(root); %change duedate of roots
flow=root;

while ~isempty(flow) %while any root exists
    stack=find(sum(taskset.prec(:,flow),2)); % find predecessors of roots
    for i=1:length(stack)
        taskset.tasks(stack(i)).DueDate=max(...
            1+taskset.tasks(find(taskset.prec(stack(i),:))).DueDate,...  % 1 + Duedate of successor
            1-taskset.tasks(stack(i)).DueDate); % 1 - DueDate of actual task "i"
    end
    flow=stack; % actual tasks are new flowroots
end

[taskset, order] = sort(taskset,'DueDate','dec'); %sort tasks in nonincreasing order

p=problem('P|prec|Cmax'); %problem overloaded
taskset=listsch(taskset,p,m); %List Scheduling method
taskset.DueDate=DueSave(order); %correction of DueDates
add_schedule(taskset,'Brucker76');


% end .. Brucker76
