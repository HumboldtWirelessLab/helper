function varargout = between(G,varargin)
%BETWEEN   Return number of edges between initial and terminal node of
%graph or number of initial and terminal node of the edge
%
% Syntax
%    edge = BETWEEN(G,IN,TN)
%     edge  - number of edge
%     G     - graph
%     IN    - number of initial node
%     TN    - number of terminal node
%
%    [IN,TN] = BETWEEN(G,edge)
%

%   Author(s):  M. Kutil, V. Navratil
%   Copyright (c) 2004 CTU FEE
%   $Revision: 1055 $  $Date: 2007-05-07 09:20:03 +0200 (po, 07 V 2007) $

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

if nargin == 3,
    IN = varargin{1};
    TN = varargin{2};
    INn = find(G.eps(:,1) == IN);
    TNn = find(G.eps(:,2) == TN);
    varargout{1} = intersect(TNn, INn);
elseif nargin == 2,
    edge = varargin{1};
    IN = G.eps(edge,1);
    TN = G.eps(edge,2);
    varargout{1} = IN;
    varargout{2} = TN;
end

%end .. @graph/between
