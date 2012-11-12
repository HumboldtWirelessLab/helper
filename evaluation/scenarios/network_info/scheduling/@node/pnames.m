function [Props,AsgnVals,DefVal] = pnames(node)
%PNAMES  All public properties and their assignable values and default
%           value
%
%   [PROPS,ASGNVALS,DEFVAL] = PNAMES(NODE)  
%     PROPS    - list of public properties of the object NODE (a cell vector)
%     ASGNVALS - assignable values for these properties (a cell vector)
%     DEFVAL   - default values
%
%   See also  GET, SET.

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
 

% Get parent object properties
[Props,AsgnVals,DefVal] = pnames(getfield(struct(node), node.parent));

% Add NODE properties
Props = {'Name' 'UserParam' 'Color' 'GraphicParam' 'TextParam' Props{:}}; 

% Also return assignable values if needed
if nargout>1,
    
    AsgnVals = {'Name of the NODE' ...
                'User parameters' ...
                'Color of the NODE' ...
                'Graphic parameters of the NODE (position, color,...)' ...
                'Position of the text (Name, UserParam)' ...
                AsgnVals{:}};
        
    if nargout>2,
        DefVal = {'' [] DefVal{:}};
    end
end

%end .. @node/pnames
