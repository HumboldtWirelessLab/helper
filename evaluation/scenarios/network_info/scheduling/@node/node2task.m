function taskout = node2task(n,varargin)
%NODE2TASK  convert node to task.
%
%    task = NODE2TASK(node[,order])
%      task   - output object of task
%      node   - object of node
%      order  - cell with ordered task's parameters which are stored in node's
%               User param
%               For example: {'Name','ProcTime','UserParam'}
%               allowed are all parameters which can be obtained be the
%               function GET: get(task). 
%
%  See also TASK, NODE, GET, TASK2NODE.

%   Author(s): M. Kutil
%   Copyright (c) 2005 CTU FEE
%   $Revision: 1047 $  $Date: 2007-05-03 11:06:15 +0200 (čt, 03 V 2007) $

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
taskout = task(1);
taskout.Name = n.Name;
if na>1
    parameters = varargin{1};
    nontransform = [];
    for i = 1: min(length(parameters),length(n.UserParam))
        try
            set(taskout,parameters{i},n.UserParam{i})
        catch
            nontransform = [nontransform i];
        end
    end
    if ~isempty(nontransform)
        if length(nontransform) == 1
            warning('User parameter %s from node with name ''%s'' can''t be transformed! (Node.UserParam was copied to Task.UserParam)',num2str(nontransform,'#%1d '),n.Name);
        else
            warning('User parameters %s from node with name ''%s'' can''t be transformed! (Node.UserParam was copied to Task.UserParam)',num2str(nontransform,'#%1d '),n.Name);
        end
        taskout.UserParam = n.UserParam;
    end
end
taskout=set_helper(taskout,'schedobj',n.schedobj);
set_graphic_param(taskout,'color',get(n,'color'));
%end .. @node/node2task