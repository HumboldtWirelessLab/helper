function value = getdata(g,property)
%GETDATA helpful function for method get. 
%
%    value = GETDATA(graph, property, varargin)
%      value     - returned object (cell, matrix,...)
%      graph     - object graph
%      property  - keyword:
%                       'edl' (list of edges)
%                       'ndl' (list of nodes)
%                       'nodeuserparamdatatype'
%                       'edgeuserparamdatatype
%                       'inc' - incidency matrix
%                       'adj' - adjacency matrix
%                       'e2p' - matrix or cell of user prameters of edges
%                       'n2p' - matrix or cell of user prameters of nodes
%
%  See also SET, GET, GRAPH, EDGE2PARAM, NODE2PARAM.

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


value = 0;
if ~isa(g,'graph')
    error('1st parameter must be graph.');
end
if ~isa(property,'char')
    error('Property must be char.');
end

switch lower(property)
    
    case {'edl', 'edgelist'}
        value = getlist(g,'edge');
        
    case {'ndl', 'nodelist'}
        value = getlist(g,'node');
        
    case {'nodeuserparamdatatype','nodesdatatype','nodedatatype','ndt'}
        value = g.DataTypes.nodes;
        
    case {'edgeuserparamdatatype','edgesdatatype','edgedatatype','edt'}
        value = g.DataTypes.edges;
        
    case {'inc', 'incidency'}
        value = inc(g);
        
    case {'adj', 'adjacency'}
        value = adj(g);
    
%     case {'e2p', 'edge2param', 'edges2param'}
%         value = edge2param(g);
%         
%     case {'n2p', 'node2param', 'nodes2param'}
%         value = node2param(g);
    
    otherwise
        error('Property %s isn''t available!', property);
        return;
end

%end .. @graph/getdata

%==============================================================================        

% g = object graph
% parameter = type of list ('node' or 'edge')
% list = created nodeList or edgeList (type cell)
function list = getlist(g,parameter)
    list = [];
    switch parameter
        % creates nodeList
        case 'node'
            nodes = g.N;
%            [numNodes,numParams] = getnums(nodes);
            if ~isempty(nodes)
                numNodes = length(nodes);
                numParams = length(nodes(1).UserParam);
                list = cell(numNodes, numParams+1);
                for i = 1:numNodes
                    list{i,1} = i;
                    for j = 1:numParams
                        try
                            list{i,j+1} = nodes(i).UserParam{j};
                        catch
                            list{i,j+1} = [];
                        end
                    end
                end
            end
        % creates edgeList
        case 'edge'
            eps = g.eps;
            edges = g.E;
%            [numEdges,numParams] = getnums(edges);
            if ~isempty(edges)
                numEdges = length(edges);
                numParams = length(edges(1).UserParam);
                list = cell(numEdges, numParams+2);   
                for i = 1:numEdges
                    list{i,1} = eps(i,1);
                    list{i,2} = eps(i,2);
                    for j = 1:numParams
                        try
                            list{i,j+2} = edges(i).UserParam{j};
                        catch
                            list{i,j+2} = [];
                        end
                    end
                end
            end
            
        otherwise
    end
    
%==============================================================================        

% % objectList = cell of nodes or edges
% % numObjects = number of edges ot nodes
% % numParams = number of parameters for each node or edge
% function [numObjects,numParams] = getnums(objectList)
%     numParams = 0;
%     numObjects = 0;
%     if ~isempty(objectList)
%         numObjects = length(objectList);
%         nums = zeros(1,numObjects);
%         for i = 1:numObjects
%             nums(i) = length(objectList{i}.UserParam);
%         end
%         numParams = max(nums);
%     end
    
%==============================================================================        
