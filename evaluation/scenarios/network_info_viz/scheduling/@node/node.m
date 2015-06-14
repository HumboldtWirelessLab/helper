function node = node(varargin)
%NODE  Creation of object node of graph.
%
%  Creation:
%    node = NODE()
%    The output node is a NODE object.
%
%  See also EDGE, GRAPH.

%   Author(s): M. Kutil
%   Copyright (c) 2004 CTU FEE
%   $Revision: 941 $  $Date: 2007-04-23 00:03:54 +0200 (po, 23 IV 2007) $

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
if na>=1 && isa(varargin{1},'node'),
    node = varargin{1};
    if na > 1,
     % TODO modify for more parameters.
    end;
    return;
elseif na == 1 && isa(varargin{1},'struct')
    node = varargin{1};

    return;
end;

% Create the structure
node = struct(...
        'parent', 'schedobj',...
        'Name','',...
        'version',0.01,...
        'UserParam',[],...
        'GraphicParam',[],...
        'TextParam',[]);
% UserParam is user paramters vector
    
% Create a parent object
parent = schedobj;
    
% Label task as an object of class TASK
node = class(node,'node', parent); 

node.GraphicParam = {getdefaultnode};

%end .. @node/node


function defaultnode = getdefaultnode
% returns default graphic shape
    defaultnode.x = [];
    defaultnode.y = [];
    defaultnode.width  = 30;
    defaultnode.height = 30;
    defaultnode.curvature = [1 1];  % circle
    defaultnode.facecolor = [1 1 0]; % yellow
    defaultnode.linewidth = 1;
    defaultnode.linestyle = '-';  % solid line
    defaultnode.edgecolor = [0 0 0]; % black
