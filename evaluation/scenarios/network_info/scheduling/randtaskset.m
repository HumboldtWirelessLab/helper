function rtaskset = randtaskset(nbTasks,varargin)
% RANDTASKSET Generates set of tasks of random parameters selected from uniform distribution.
%
% Synopsis
%    RTASKSET =
%    RANDTASKSET(nbTasks,[Name,]ProcTime[,ReleaseTime[,Deadline ...
%                [,DueDate[,Weight[,Processor]]]]])
%
% Description
%    Function has following parameters:
%      nbTasks:
%                   - number of tasks in set of tasks
%      Name:
%                   - name of the tasks (must by char!)
%      ProcTime:
%                   - range of processing time (execution time)
%      ReleaseTime:
%                   - range of release date (arrival time)
%      Deadline:
%                   - range of deadline
%      DueDate:
%                   - range of due date
%      Weight:
%                   - range of weight (priotiry)
%      Processor:
%                   - range of dedicated processor
%
%    The output RTASKSET is a TASKSET object.
%
% See also TASKSET/TASKSET

%   Author(s): M.Stibor
%   Copyright (c) 2004 CTU FEE
%   $Revision: 1856 $  $Date: 2007-10-10 10:35:23 +0200 (st, 10 X 2007) $

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


for i=1:nbTasks
    rtask = randtask(varargin{:});
    if i==1
        rtaskset = [rtask];
    else
        rtaskset = [rtaskset rtask];
    end
end

% if name is defined, index it!
if nargin>=1
    if isa(varargin{1},'char')
        for i=1:nbTasks
            names{i} = [varargin{1} '_{' num2str(i) '}'];
        end
        rtaskset.Name = names;
    end
end

% end of RANDTASKSET
