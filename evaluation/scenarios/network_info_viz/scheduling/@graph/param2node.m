function g = param2node(g,param,varargin)
%PARAM2NODE  add to graph's user parameters datas from cell or matrix.
%
% Synopsis
%    graph = PARAM2NODE(graph,param)
%    graph = PARAM2EDGE(graph,param,N)
%
% Description
%    graph = PARAM2NODE(graph,param)
%      graph     - object graph 
%      userparam - array (1 parameter in matrix) or cell (several 
%                  parameters) with user params for nodes.
%
%    graph = PARAM2EDGE(graph,param,N)
%      graph     - object graph userparam - array or cell with user params
%                  for nodes
%      N         - N-th position in UserParam (new UserParams replace
%                  original UserParams).
%
%
%  See also GRAPH/NODE2PARAM, GRAPH/GRAPH, GRAPH/EDGE2PARAM, GRAPH/PARAM2EDGE.

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

    if nargin > 2
        n = varargin{1};
        if length(n) > 1
            n = n(1);
        end
    else
        n = 1;    
    end
        
    try
        
        if length(g.N) ~= length(param)
            error('Number of parameters doesn''t match number of nodes in the graph.');
        end 

        dataTypes = g.DataTypes.nodes;
        
        if iscell(param)
            
            [g.N,dataTypes] = setcellparams(g.N,param,dataTypes,n);
            
        else
            
            [g.N,dataTypes] = setarrayparams(g.N,param,dataTypes,n);    
            g.DataTypes.nodes{n} = 'double';
            
        end

    catch
        rethrow(lasterror);
    end

    
%end .. @graph/param2node    


%=======================================================================

function [nodes,dataTypes] = setarrayparams(nodes,param,dataTypes,n)

    if isempty(dataTypes) || isempty(dataTypes{n}) || dataTypes{n} == 'double' 
        
        for i = 1:length(nodes)
            nodes(i).UserParam{n} = param(i);
        end
        
    else
        error('Data type of parameter doesn''t match with value.');
    end

%=======================================================================

function [nodes,dataTypes] = setcellparams(nodes,param,dataTypes,n)
   
    numDataTypes = length(dataTypes);
    for i = 1:length(nodes)
        param_tmp = param{i};
        if iscell(param_tmp)
            for j = 1:length(param_tmp)
                if isempty(dataTypes) || numDataTypes < (n+length(param_tmp)-1) ||...
                   isempty(dataTypes{n+j-1}) || isa(param_tmp{j},dataTypes{n+j-1})
                    nodes(i).UserParam{n+j-1} = param_tmp{j};
                else
                    nodes(i).UserParam{n+j-1} = paramconversion(param_tmp{j},dataTypes{n+j-1});
                    warning('TORSCHE:graph:conversionDataTypesPermformed',...
                        'Value of parameters doesn''t match witch data type. Conversion was performed.');               
                end
            end
        else
            if isempty(dataTypes) || numDataTypes < n ||...
               isempty(dataTypes{n}) || isa(param_tmp,dataTypes{n})
                nodes(i).UserParam{n} = param_tmp;
            else
                nodes(i).UserParam{n} = paramconversion(param_tmp,dataTypes{n});
                warning('TORSCHE:graph:conversionDataTypesPermformed',...
                        'Value of parameters doesn''t match witch data type. Conversion was performed.');               
            end
        end
    end

%=======================================================================

function value = paramconversion(value,dataType)
	switch dataType
        case 'double'
            value = double(value);
        case 'logical'
            value = logical(value);
        case 'cell'
            value = cell(value);
        case 'struct'
            value = struct(value);
        case 'char'
            value = char(value);
        otherwise
            value = eval([dataType '([])']);
	end

%=======================================================================
    
