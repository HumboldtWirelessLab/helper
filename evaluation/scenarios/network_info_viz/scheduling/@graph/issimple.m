function isSimple = issimple(g,varargin)
%ISSIMPLE   True for simple graph (graph without parallel edges)
%
%       ISSIMPLE(G) returns 1 if G is a simple graph and 0 otherwise.
%       Graph G can be represented by object GRAPH or adjacency matrix.
%
%       ISSIMPLE(graph,ADJ) returns logical 1 if ADJ represents graph
%       without parallel edges and logical 0 otherwise. ADJ is adjacency
%       matrix of graph.
%
%
%   See also GRAPH, ISSELFLOOP, ISCYCLIC.

%   Author(s):  V. Navratil
%   Copyright (c) 2004 CTU FEE
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

    if nargin == 1 && isa(g,'graph')
        adjMatrix = get(g,'adj');       % getting of adjacency matrix    
    elseif nargin == 2 && isa(varargin{1},'double')
        adjMatrix = varargin{1};    
    else
        error('Input graph must be specified by object GRAPH or by adjacency matrix.');
    end

    isSimple = true;
    if find(adjMatrix > 1)
        isSimple = false;
    end
    
%end .. @graph/issimple
