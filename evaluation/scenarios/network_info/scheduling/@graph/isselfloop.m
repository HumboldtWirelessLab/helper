function isSelfLoop = isselfloop(g,varargin)
%ISSELFLOOP   True for graph with loop.
%
%       ISSELFLOOP(G) returns logical 1 if G has loop and logical 0
%       otherwise. Graph G must be represented as object GRAPH.
%
%       ISSELFLOOP(graph,ADJ) returns logical 1 if ADJ represents graph
%       with loop and logical 0 otherwise. ADJ is adjacency matrix of
%       graph.
%
%
%   See also GRAPH, ISCYCLIC, ISSIMPLE.

%   Author(s):  V. Navratil
%   Copyright (c) 2004 CTU FEE
%   $Revision: 702 $  $Date: 2007-03-07 23:37:21 +0100 (st, 07 III 2007) $

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


    isSelfLoop = false;
    
    % test of graph object
    if nargin == 1 && isa(g,'graph')    
        eps = g.eps;
        if ~isempty(eps) && ~isempty(find(eps(:,1) == eps(:,2)))
            isSelfLoop = true;
            return;
        end

        
    % test of adjacency matrix
    elseif nargin == 2 && isa(varargin{1},'double')
        if rank(diag(varargin{1})) > 0 
            isSelfLoop = true;
            return;
        end
        
        
    else
        error('Input graph must be specified by object GRAPH or by adjacency matrix.');
    end


%end .. @graph/isselfloop
