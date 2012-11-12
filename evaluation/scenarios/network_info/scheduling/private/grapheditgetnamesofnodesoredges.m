function [listNames,listHandles] = grapheditgetnamesofnodesoredges(param)
%GRAPHEDITGETNAMESOFNODESOREDGES returns list of names and handles of all created nodes or edges. 
%   This file is part of Scheduling Toolbox.
%
%   listNames - list of names - type cell
%   listHandles - list of handles - numeric array
%

%   Author: V. Navratil
%   Created in terms of Bachelor project 2006
%   Department of Control Engineering, FEE, CTU Prague, Czech Republic
%


    saveStructure = get(gca,'UserData');
    listNames = []; listHandles = []; name = [];
    switch (param)
        case ('nodes')
            if ~isempty(saveStructure.node)
                for i = 1:length(saveStructure.node)  
                    rectangleStructure = get(saveStructure.node(i),'UserData');
                    objNode = rectangleStructure.node;
                    if (~isempty(objNode.name) || (strcmp(objNode.name,' ') == 0))
                        name = objNode.name;
                        hObject = saveStructure.node(i);
                    end
                    if isempty(listNames)
                        listNames = {name};
                        listHandles = hObject;
                    else
                        listNames(i) = {name};
                        listHandles(i) = hObject;
                    end
                end
            end
        case ('edges')
            if ~isempty(saveStructure.edge)
                for i = 1:length(saveStructure.edge(:,1))  
                    lineStructure = get(saveStructure.edge(i,1),'UserData');
                    objEdge = lineStructure.edge;
                    if (~isempty(objEdge.name) || (strcmp(objEdge.name,' ') == 0))
                        name = objEdge.name;
                        hObject = saveStructure.edge(i,1);
                    end
                    if isempty(listNames)
                        listNames = {name};
                        listHandles = hObject;
                    else
                        listNames(i) = {name};
                        listHandles(i) = hObject;
                    end
                end     
            end
    end
