function g = matrixparam2edges(g,param,varargin)
%MATRIXPARAM2EDGES assigns user parameters to graph.
%    G = EDGES2PARAM(G,USERPARAM) assigns to user param
%    (UserParam) of edges in graph G data from matrix USERPARAM.
%
%    G = EDGES2PARAM(G,USERPARAM,N) assigns the data to 
%    N-th position in UserParam.
%
%    G = EDGES2PARAM(G,USERPARAM,N,NOTEDGEPARAM) defines value of
%    user parameter for missing edges. This value is used for checking 
%    consistence between graph G and matrix USERPARAM (default is INF).
%
%  See also PARAM2EDGES, GRAPH, EDGES2MATRIXPARAM.

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
if(nargin>=3)
    paramCat = varargin{1};     %Order of the input data in UserParam
else
    paramCat = 1;
end;

if(nargin>=4)
    notEdgeParam = varargin{2};
end;

for from = 1 : size(param,1)
    for to = 1 : size(param,2)
        edges = between(g,from,to);
        if(length(edges)>1)
            error('Input graph contains parallel edges.');
        end;
        
        if(length(edges)==1 & param(from,to)~=notEdgeParam)
            edgeUserParam=g.E(edges(1)).UserParam;
            edgeUserParam{paramCat}=param(from,to);
            g.E(edges(1)).UserParam=edgeUserParam;
        end;
        
        if((length(edges)==0 & param(from,to)~=notEdgeParam) | (length(edges)==1 & param(from,to)==notEdgeParam))
            error('Matrix of parameters ''param'' doesn''t match with the input graph.');
        end;        
    end
end

%end .. @graph/param2edges
