function parameters = task2userparam(t,varargin)
%TASK2USERPARAM  return task's parameters as cell.
%
%  Creation:
%    parameters = TASK2USERPARAM(task[,order])
%      parameters  - task's parameters as cell
%      task        - object of task
%      order       - cell with order output parameters
%                    For example: {'Name','ProcTime'}
%                    allowed are all parameters which can be obtained be
%                    the function GET: get(task).
%
%  See also TASK, GET.

%   Author(s): M. Kutil
%   Copyright (c) 2005 CTU FEE
%   $Revision: 144 $  $Date: 2005-06-08 09:11:44 +0200 (st, 08 VI 2005) $

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
 
na = nargin;
paramorder = {};
parameters = [];
if na>1
    if iscell(varargin{1})
        paramorder = varargin{1};
        if length(paramorder) == 1 & iscell(paramorder{1})
            paramorder = paramorder{1};
        end
    end
end
try
    for i=1:length(paramorder)
        parameters{i} = get(t,paramorder{i});
    end
catch
    rethrow(lasterror);
end
%end .. @task/task2userparam