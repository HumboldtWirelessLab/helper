function UserParam = edges2param(g,varargin)
%EDGES2PARAM  return taskset's user parameter describing edges' user parameter.
%
%    userparam = EDGES2PARAM(graph)
%      graph     - object graph
%      userparam - output user param
%
%    userparam = EDGES2PARAM(graph,n)
%      graph     - object graph
%      n         - number (or array of numbers) of wanted user param. All
%                  params are return if 0 is used.
%      userparam - output user param
%
%  See also TASKSET, GRAPH.

%   Author(s): M. Kutil
%   Copyright (c) 2005 CTU FEE
%   $Revision: 687 $  $Date: 2007-03-05 12:18:57 +0100 (po, 05 III 2007) $

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

n = 0;
if nargin > 1
    n = varargin{1};
    if isempty(n)
        n = 0;
    end
end

numNodes = length(adj(g));
UserParamCount = zeros(numNodes);
UserParam{numNodes,numNodes} = [];

try
    if n==0
        for i = 1:size(g.eps,1)
            param = g.E{i}.UserParam;
            UserParamCount(g.eps(i,1),g.eps(i,2)) = UserParamCount(g.eps(i,1),g.eps(i,2))+1;
            UserParam{g.eps(i,1),g.eps(i,2)}{UserParamCount(g.eps(i,1),g.eps(i,2))} = param(1:end);
        end
    else
        for i = 1:size(g.eps,1)
            param = g.E{i}.UserParam;
            UserParamCount(g.eps(i,1),g.eps(i,2)) = UserParamCount(g.eps(i,1),g.eps(i,2))+1;
            UserParam{g.eps(i,1),g.eps(i,2)}{UserParamCount(g.eps(i,1),g.eps(i,2))} = param(n);
        end
    end
catch
    error('Invalid param format!');
end

%end .. @graph/edges2param
