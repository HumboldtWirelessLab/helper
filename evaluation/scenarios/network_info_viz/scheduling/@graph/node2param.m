function outUserParams = node2param(g,varargin)
%NODE2PARAM returns user parameters of nodes in graph
%
% Synopsis
%   USERPARAM = NODE2PARAM(G)
%   USERPARAM = NODE2PARAM(G,i)
%
% Description
%   USERPARAM = NODE2PARAM(G) returns array or cell of all UserParams of
%   nodes in graph G.
%
%   USERPARAM = NODE2PARAM(G,i) returns array or cell of i-th UserParam of
%   nodes in graph G. If i is array the function returns cell similar to
%   array.
%
%   See also GRAPH/GRAPH, GRAPH/PARAM2NODE, GRAPH/EDGE2PARAM, GRAPH/PARAM2EDGE.

%   Author(s): V. Navratil
%   Copyright (c) 2005 CTU FEE
%   $Revision: 1833 $  $Date: 2007-09-21 15:04:54 +0200 (pá, 21 IX 2007) $

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
 
%     try
        
        if nargin > 1
            n = varargin{1};
        else
            n = 1:length(g.N(1).UserParam);
        end

        if length(n) == 1 &&...
                (isempty(g.DataTypes.nodes) || isempty(g.DataTypes.nodes{n}) ||...
                isnumeric(eval([g.DataTypes.nodes{n} '('''')'])))
            try
                outUserParams = getarrayofparams(g,n);
            catch
                outUserParams = getcellofparams(g,n);
            end
        else
            outUserParams = getcellofparams(g,n);
        end
        
%     catch
%         rethrow(lasterror);
% %        error('There are no UserParams in the nodes.');
%     end
    
%end .. @graph/node2param


%==========================================================

function outUserParams = getarrayofparams(g,n)
    nodes = g.N;
    numNodes = length(nodes);
    outUserParams = zeros(1,numNodes);
    for i = 1:numNodes
        outUserParams(i) = nodes(i).UserParam{n};
    end

%==========================================================

function outUserParams = getcellofparams(g,n)
    nodes = g.N;
    numNodes = length(nodes);
    outUserParams = cell(1,numNodes);
    for i = 1:numNodes
        outUserParams{i} = nodes(i).UserParam(n);
    end

%==========================================================
