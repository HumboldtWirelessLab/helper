function nodeout = task2node(t,varargin)
%TASK2NODE  convert task to node.
%
%    node = TASK2NODE(task[,order])
%      node   - output object of node
%      task   - object of task
%      order  - cell with ordered task's parameters which will be stored to
%               node's User param
%               For example: {'Name','ProcTime','UserParam'}
%               allowed are all parameters which can be obtained be the
%               function GET: get(task). 
%
%  See also TASK, NODE, GET, NODE2TASK, TASK2USERPARAM.

%   Author(s): M. Kutil
%   Copyright (c) 2005 CTU FEE
%   $Revision: 1054 $  $Date: 2007-05-07 09:17:58 +0200 (po, 07 V 2007) $

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
nodeout = node;
nodeout.Name = t.Name;
if na>1
    nodeout.UserParam = task2userparam(t,varargin{1});
end
nodeout=set_helper(nodeout,'schedobj',t.schedobj);
color = get_graphic_param(t,'color');
if iscolor(color),
    set(nodeout,'color',color);
end
%end .. @task/task2node