function edge = edge(varargin)
%EDGE  Creation of object edge of graph.
%
%  Creation:
%    edge = EDGE()
%    The output edge is a EDGE object.
%
%  See also NODE, GRAPH.

%   Author(s): M. Kutil
%   Copyright (c) 2004 CTU FEE
%   $Revision: 827 $  $Date: 2007-03-26 11:51:18 +0200 (po, 26 III 2007) $

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
 

na = nargin;
if na>=1 && isa(varargin{1},'edge'),
   edge = varargin{1};
   if na > 1,
     % TODO modify for more parameters.
   end;
   return;
end;    

% Create the structure
edge = struct(...
        'parent', 'schedobj',...
        'Name','',...
        'version',0.01,...
        'UserParam',[],...
        'Color',[],...
        'Position',[],...
        'LineStyle',[],...
        'LineWidth',[],...
        'Arrow',[],...
        'TextParam',[],...
        'Undirected',0);
    
% UserParam is user paramters vector
    
% Create a parent object
parent = schedobj;
    
% Label task as an object of class TASK
edge = class(edge,'edge', parent); 

%end .. @edge/edge