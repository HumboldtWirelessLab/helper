function value = getdata(n,property)
%GETDATA helpful function for method get. 
%
%    value = GETDATA(node, property, varargin)
%      value     - returned object (cell, matrix,...)
%      node      - object node
%      property  - keyword:
%                       'Color' (list of edges)
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


value = 0;
if ~isa(n,'node')
    error('1st parameter must be node.');
end
if ~isa(property,'char')
    error('Property must be char.');
end

switch lower(property)
    
    case {'color', 'clr'}
        value = getnodecolor(n);
        
    otherwise
        error('Property %s isn''t available!', property);
        return;
end

%end .. @graph/getdata

%==============================================================================        

function color = getnodecolor(n)
    try
        color = [];
        for i = 1:length(n.GraphicParam)
            if isfield(n.GraphicParam{i},'facecolor')
                color = n.GraphicParam{i}.facecolor;
            end
        end
    catch
        n2 = node;
        color = n2.GraphicParam{1}.facecolor;
    end
    
%==============================================================================        
