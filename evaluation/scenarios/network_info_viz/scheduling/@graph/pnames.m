function [Props,AsgnVals,DefVal] = pnames(graph)
%PNAMES  All public properties and their assignable values and default
%           value
%
%   [PROPS,ASGNVALS,DEFVAL] = PNAMES(graph)  
%     PROPS    - list of public properties of the object graph (a cell vector)
%     ASGNVALS - assignable values for these properties (a cell vector)
%     DEFVAL   - default values
%
%   See also  GET, SET.

%   Author(s): M. Kutil
%   Copyright (c) 2004 CTU FEE
%   $Revision: 686 $  $Date: 2007-03-05 00:10:16 +0100 (po, 05 III 2007) $

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
[Props,AsgnVals,DefVal] = pnames(getfield(struct(graph), graph.parent));

% Add graph properties
Props = {'Name' 'N' 'E' 'UserParam' 'DataTypes' 'Color' 'GridFreq' Props{:} ...
         'inc' 'adj' 'edl' 'ndl' 'edgeUserparamDatatype' 'nodeUserparamDatatype'};

% Also return assignable values if needed
if nargout>1,
    
    AsgnVals = {'Name of the GRAPHS' ...
                'Array of nodes' ...
                'Array of edges' ...
                'User parameters' ...
                'Type of UserParam''s data' ...
                'Color of area of the GRAPH' ...
                'Grid frequency' ...
                AsgnVals{:} ...
                'Incidency matrix' ...
                'Adjacency matrix' ...
                'List of edges (cell)' ...
                'List of nodes (cell)' ...
                'Cell of data types of edges'' UserParam' ...
                'Cell of data types of nodes'' UserParam'};

    if nargout>2,
        DefVal = {'' [] [] [] DefVal{:}};
    end
end

%end .. @graph/pnames
