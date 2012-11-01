function g = param2edges(g,param,varargin)
%PARAM2EDGES  add to graph's user parameters datas from call.
%
%    graph = EDGES2PARAM(graph,userparam)
%      graph     - object graph
%      userparam - cell with user params for edges
%
%    graph = EDGES2PARAM(graph,userparam,N)
%      graph     - object graph
%      userparam - cell with user params for edges
%      N         - N-th position in UserParam.
%
%  See also TASKSET, GRAPH.

%   Author(s): M. Kutil
%   Copyright (c) 2005 CTU FEE
%   $Revision: 674 $  $Date: 2007-03-02 09:34:43 +0100 (pá, 02 III 2007) $

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

try
    paramCat = 1;
    if nargin >= 3
        paramCat = varargin{1};
        if isempty(paramCat)
            paramCat = 1;
        end
    end

    for from = 1 : size(param,1)
        for to = 1 : size(param,2)
            edges = between(g,from,to);
            for n = 1 : min(length(param{from,to}),length(edges))
                param_items = param{from,to};
                if iscell(param_items)
                    param_tmp = param_items{n};
                    for m = 1:length(param_tmp)
                        if iscell(param_tmp)
                            g.E(edges(n)).UserParam{paramCat+m-1} = param_tmp{m};
                        else
                            g.E(edges(n)).UserParam{paramCat+m-1} = param_tmp;
                        end
                    end
                else
                    g.E(edges(n)).UserParam{paramCat} = param_items;
                end
            end
        end
    end
catch
    %rethrow(lasterror);
    error('Invalid param format!');
end


%end .. @graph/param2edges