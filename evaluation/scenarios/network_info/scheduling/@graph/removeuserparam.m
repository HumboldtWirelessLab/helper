function g = removeuserparam(g,type,listOfParams)
%REMOVEUSERPARAM  Removes ordered user parameter or parameters.
%
%    graph = REMOVEUSERPARAM(graph,type,listOfParams)
%      graph        - object graph
%      type         - object type in string 
%                       => type = 'node';
%                          type = 'edge';
%      listOfParams - number (or array of numbers) of UserParam to removal
%           listOfParams = 2;
%           listOfParams = [2 3 4];
%           listOfParams = [2:4];
%
%  See also REMOVENODE, REMOVEEDGE, GRAPH, NODE, EDGE.

%   Author(s): V. Navratil
%   Copyright (c) 2005 CTU FEE
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

try
    switch lower(type)
        case {'node','nodes','n'}
            [g.N,g.DataTypes.nodes] = remove(g.N,listOfParams,g.DataTypes.nodes);
            
        case {'edge','edges','e'}
            [g.E,g.DataTypes.edges] = remove(g.E,listOfParams,g.DataTypes.edges);
            
        otherwise
            error('Such type of object is not available.');
    end
catch
    rethrow(lasterror);
end
    
%end .. @graph/removeuserparam

%========================================================================

function [list,dataTypes] = remove(list,listOfParams,dataTypes)
    
    numParams = length(dataTypes);
    if numParams > 0 && max(listOfParams) > numParams
        error('TORSCHE:graph:tooManyNodes', ['There are ' num2str(numParams) ' user parameters.']);
        return;
    else
 
    try        
        dataTypes(listOfParams) = [];
    catch
    end
        for i = 1:length(list)
%             try
%                 list{i}.UserParam(listOfParams) = [];
%             catch
                list(i).UserParam(listOfParams) = [];
%             end
        end
        
    end

%========================================================================

    