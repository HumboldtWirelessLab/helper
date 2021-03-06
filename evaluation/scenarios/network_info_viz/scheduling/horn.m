function [TS] = horn (T, prob)
%HORN computes schedule with Horn'74 algorithm
%
% Synopsis
%           TS = horn(T, problem)
%
% Description
%  TS = horn(T, problem) adds schedule to the set of tasks
%   Parameters:
%    T:
%      - input set of tasks
%    TS:
%      - set of tasks with a schedule
%    problem:
%      - description of scheduling problem - '1|pmtn,rj|Lmax'
%
% See also PROBLEM/PROBLEM, TASKSET/TASKSET, ALG1RJCMAX, ALG1SUMUJ.

%   Author(s): M. Kutil
%   Copyright (c) 2004 CTU FEE
%   $Revision: 1812 $  $Date: 2007-09-21 13:35:07 +0200 (pá, 21 IX 2007) $

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
 

if ~(is(prob,'alpha','1') && is(prob,'betha','pmtn,rj') && is(prob,'gamma','Lmax'))
    error('This problem can''t be solved by Horn algorithm.');
end
    
    timeMark1 = cputime;
    % init
    taskStart{count(T)} = [];
    taskLength{count(T)} = [];
    
    ReleaseTime = get(T,'ReleaseTime');
    DueDate = get(T,'DueDate');
    ProcTime = get(T,'ProcTime');
    inTau = 1:count(T);

    % Algorithm start 
    % SEE Blazewicz - Scheduling Computer and Manufacturing Processes
    %     2. edition, page 99, Algorithm 4.3.2
    while ~isempty(inTau)
        ReleaseTimeJ = ReleaseTime(inTau);
        ro1 = min(ReleaseTimeJ);
        if all(ro1 == ReleaseTimeJ)
            ro2 = inf;
        else 
            ro2 = min(ReleaseTimeJ(find(ro1~=ReleaseTimeJ)));
        end
        EnabledIndex = intersect(find(ro1 == ReleaseTime) , inTau);
        [minNULL,k]=min(DueDate(EnabledIndex));
        k = EnabledIndex(k(1));
        l = min(ProcTime(k),ro2-ro1);
        
        if ~isempty(taskStart{k}) && ...
                (taskStart{k}(end)+taskLength{k}(end) == ro1)
            taskLength{k}(end) = taskLength{k}(end)+l;
        else
            taskStart{k} = [taskStart{k} ro1];
            taskLength{k} = [taskLength{k} l];
        end
        
        if ProcTime(k) <= l
            inTau = inTau(find(k~=inTau));
        else
            ProcTime(k) = ProcTime(k) - l;           
        end      
        ReleaseTime(EnabledIndex) = ro1 + l;
    end
    % Algorithm finishing
    description = 'Horn''s algorithm';
    add_schedule(T,'time',cputime - timeMark1);
    add_schedule(T,description,taskStart,taskLength);
    TS = T;

% end .. horn
