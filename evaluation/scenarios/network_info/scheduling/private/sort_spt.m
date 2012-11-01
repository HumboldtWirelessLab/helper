function [taskset, order] = sort_spt(taskset, varargin)
%The Shortest Processing Time first is a scheduling strategy described by Blazewicz. 
%
%    [taskset order] = sort_spt(taskset [, iteration, processor]) add schedule to set of tasks 
%      taskset   - set of tasks
%      order     - list with re-arranged order
%      iteration - actual iteration
%      processor - processor with minimal time
%
%    see also LISTSCH

%   Author(s): M. Kutil, M. Stibor
%   Copyright (c) 2005 CTU FEE
%   $Revision: 410 $  $Date: 2006-03-28 22:26:59 +0200 (út, 28 III 2006) $

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

if nargin>1
    if varargin{1}>1
        order = 1:length(taskset);
        return    
    end
end

proctime = taskset.proctime(1,:); % identical processors
if nargin>=3 
    if size(taskset.proctime,1)>=varargin{2} 
    proctime = taskset.proctime(varargin{2},:); % uniform processors
    end
end

wproctime = proctime./taskset.weight;
[taskset order]=sort(taskset,wproctime,'inc'); % sort taskset

% end of sort_spt.m