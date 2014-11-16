function outUserParams = edge2param(g,varargin)
%EDGE2PARAM returns user parameters of edges in graph
%
% Synopsis
%   USERPARAM = EDGE2PARAM(G)
%   USERPARAM = EDGE2PARAM(G,I)
%   USERPARAM = EDGE2PARAM(G,I,NOTEDGEPARAM)
%
% Description
%   USERPARAM = EDGE2PARAM(G) returns cell with all UserParams. If there is
%   not an edge between two nodes, the user parameter is empty array []. 
%
%   USERPARAM = EDGE2PARAM(G,I) returns matrix of I-th UserParam of
%   edges in graph G. The function returns cell similar to matrix if I is
%   array.
%
%   USERPARAM = EDGE2PARAM(G,I,NOTEDGEPARAM) defines value of user
%   parameter for missing edges (default is INF). Parameter NOTEDGEPARAM is
%   disabled for graph with parallel edges.
%
%
%   See also GRAPH/GRAPH, GRAPH/PARAM2EDGE, GRAPH/NODE2PARAM, GRAPH/PARAM2NODE.

%   Author(s): V. Navratil
%   Copyright (c) 2005 CTU FEE
%   $Revision: 1830 $  $Date: 2007-09-21 14:51:16 +0200 (pá, 21 IX 2007) $

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


    if nargin > 1
        if isa(varargin{1},'double')
            n = varargin{1};
        else
            error('Position in UserParam must be double.');
        end
        try
            outUserParams = edges2matrixparam(g,n,varargin{2:end});
        catch
            try
                if nargin > 2
                    warning('TORSCHE:edge2param:tooManyParameters',...
                        'Too many input parameters was ordered. Redundant parameters were ignored.');
                end
                outUserParams = edges2param(g,n);
            catch
                rethrow(lasterror);
            end
        end
    else
        outUserParams = edges2param(g);
    end
    
    
        
    
%end .. @graph/edge2param
