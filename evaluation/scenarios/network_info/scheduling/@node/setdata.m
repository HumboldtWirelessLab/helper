function nOut = setdata(nIn,property,value)
%SETDATA helpful function for method set. 
%
%    graph = SETDATA(node, property, varargin)
%      node     - object node
%      property  - keyword:
%                       'Color' color of node for graph coloring
%
%  See also SET, GET, NODE.

%   Author(s): V. Navratil
%   Copyright (c) 2005 CTU FEE
%   $Revision: 1896 $  $Date: 2007-10-12 08:13:54 +0200 (pá, 12 X 2007) $

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

if ~isa(nIn,'node')
    error('1st parameter must be node.');
end
if ~isa(property,'char')
    error('Property has to be char.');
end

try
    switch lower(property)
        
        case {'color', 'clr'}
            if iscolor(value),
                nOut = setnodecolor(nIn, value);
            else
                error('RGB vector is required as value.');
            end
                        
        otherwise
            error('Property %s isn''t available!', property);
            return;
    end
catch
    rethrow(lasterror);
end

%==============================================================================        

function nOut = setnodecolor(nOut,color)
    try
        if iscell(nOut.GraphicParam)
            structure = nOut.GraphicParam{1};
        else
            structure = nOut.GraphicParam;
            nOut.GraphicParam = [];
        end
        if isfield(structure,'facecolor')
            structure.facecolor = color;
            nOut.GraphicParam{1} = structure;
        else
            newRectangle.x = -2;
            newRectangle.y = -2;
            newRectangle.width = 10;
            newRectangle.height = 10;            
            newRectangle.curvature = 0;
            newRectangle.facecolor = color;
            newRectangle.edgecolor = [0 0 0];
            newRectangle.linestyle = '-';
            newRectangle.linewidth = 1;
            nOut.GraphicParam{end+1} = newRectangle;
        end
    catch
        rethrow(lasterror);
        return;
    end

