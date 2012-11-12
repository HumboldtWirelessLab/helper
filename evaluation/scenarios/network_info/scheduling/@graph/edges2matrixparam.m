function UserParam = edges2matrixparam(g,varargin)
%EDGES2MATRIXPARAM returns user parameters of edges in graph
%   USERPARAM = EDGES2MATRIXPARAM(G) returns first user parameter on
%   edges in graph G. If there is not an edge between two nodes, the
%   corresponding user parameter is considered to be INF. If there
%   are parallel edges the algorithm returns error message.
%
%   USERPARAM = EDGES2MATRIXPARAM(G,N) returns N-th user parameter on
%   edges in graph G.
%
%   USERPARAM = EDGES2MATRIXPARAM(G,N,NOTEDGEPARAM) defines value of
%   user parameter for missing edges (default is INF).
%
%   See also EDGES2PARAM, GRAPH, MATRIXPARAM2EDGES.

%   Author(s): P. Sucha
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

notEdgeParam = inf;
if (nargin >= 2)
    paramCat = varargin{1};
else
    paramCat = 1;
end

if (nargin >= 3)
    notEdgeParam = varargin{2};
end

n=length(adj(g));
UserParamCount = zeros(n);
UserParam = notEdgeParam*ones(n);

for i = 1:size(g.eps,1)
    if(length(g.E(i).UserParam)>=paramCat)
        param = g.E(i).UserParam{paramCat};
    else
        param = notEdgeParam;
    end
    if(~isa(param,'numeric'))
        error('A parametr on an edge is not number.');
    end
    if(UserParamCount(g.eps(i,1),g.eps(i,2))>0)
        error('Input graph contains parallel edges.');
    end
    UserParamCount(g.eps(i,1),g.eps(i,2)) = 1;
    UserParam(g.eps(i,1),g.eps(i,2)) = param;
end

%end .. @graph/edges2matrixparam
