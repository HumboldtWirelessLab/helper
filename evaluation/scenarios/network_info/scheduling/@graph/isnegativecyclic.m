function isNegCyclic = isnegativecyclic(g,varargin)
%ISNEGATIVECYCLIC   True for cyclic graph with negative cycle
%
%       ISNEGATIVECYCLIC(G) returns 1 if G is a graph containing negative
%       cycle and 0 otherwise. Graph G can be represented by object GRAPH.
%
%       ISNEGATIVECYCLIC(G,'pos',N) defines position in edges' UserParam
%       (default is N = 1).
%
%       ISNEGATIVECYCLIC(graph,ADJ) returns logical 1 if ADJ represents graph
%       containing negative cycle and logical 0 otherwise. ADJ is
%       "adjacency" matrix with costs of edges.
%
%       ISNEGATIVECYCLIC(graph,ADJ,VALUE) defines value of cost for missing
%       edges (default is INF).
%
%   See also GRAPH, ISSIMPLE, ISSELFLOOP, ISCYCLIC.

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

    % fitting of input
    if nargin == 1 && isa(g,'graph')
        matrix = edge2param(g,1,Inf);           % getting UserParam from graph, position 1
    elseif nargin == 2 && isa(varargin{1},'double')
        matrix = varargin{1};
        % input data is matrix of costs
    elseif nargin > 2 && isa(varargin{1},'char') && isa(varargin{2},'double') &&...
           ( strcmp(varargin{1},'pos') || strcmp(varargin{1},'position') || strcmp(varargin{1},'pup') )
        matrix = edge2param(g,varargin{2},Inf); % getting UserParam from graph, position varargin{2}
    elseif nargin > 2 && isa(varargin{1},'double') && isa(varargin{2},'double')
        matrix = varargin{1};                   % input data is matrix of costs
        matrix(matrix == varargin{2}) = Inf;              % cost for missing edges is not default
    else
        error('Input graph must be specified by object GRAPH or by matrix of costs.');
    end
    
    if iscell(matrix)   % edge2param returns cell for multi-graphs or if param of edge is not numeric.
        error(sprintf('Graph with parallel edges is not supported. \nParameter of edges must be double.'));
    end

    
    isNegCyclic = false;
    
    n = size(matrix,1);
    
    for k = 1:n 				
        for i = 1:n 				
            for j = 1:n 
                if (matrix(i,j) > matrix(i,k) + matrix(k,j)),
                    matrix(i,j) = matrix(i,k) + matrix(k,j);
                    if matrix(i,i) < 0,
                         isNegCyclic = true;
                         return;
                    end
                end
            end
        end
    end
    
    
%     isNegCyclic = false;
%     M = floyd(g);
%     for i = 1:size(M,1)
%         if ~isempty(find(M(i,i) < 0))
%             isNegCyclic = true;
%             return;
%         end
%     end
    
    
