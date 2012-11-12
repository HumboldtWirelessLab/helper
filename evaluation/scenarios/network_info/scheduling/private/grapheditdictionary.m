function property = grapheditdictionary(varargin)
%DICTIONARY for getting properties of selected object graph, node, edge.
%   This file is part of Scheduling Toolbox.
%
%   property - list of properties including their actual values
%

%   Author: V. Navratil
%   Created in terms of Bachelor project 2006
%   Department of Control Engineering, FEE, CTU Prague, Czech Republic
%

    
    if(nargin == 1 && isnumeric(varargin{1}))
        
        object = get(varargin{1});
        i = 1;
        switch(object.Type)
                
            case('axes')
                saveStructure = get(varargin{1},'UserData');
   %             if ~isempty(saveStructure)
                    objGraph = saveStructure.graph;
                    params = fieldnames(get(objGraph));
                        
                    params{length(params)+1} = 'Color'; params{length(params)+1} = 'X'; params{length(params)+1} = 'Y';
                    
                    i = 1;
                    wasColor = 0;
                    while ~isempty(params)
                        if (strcmp('Name',params{1}) || strcmp('Notes',params{1}))
                            if (i == 1)
                                property = getProperty('Text',params(1),get(objGraph,params{1}));
                            else
                                property(i) = getProperty('Text',params(1),get(objGraph,params{1}));
                            end   
                            i=i+1;
                        elseif (strcmp('UserParam',params{1}))
                            %assignin('base','X',get(objGraph,params{i}));
                            property(i) = getProperty('OtherLocked',params{1},get(objGraph,params{1}));
                            i=i+1;
                        elseif (strcmp('Color',params{1}) && ~wasColor)
                            value = get_graphic_param(objGraph,params{1});
                            if (length(value) ~= 3) value = [1 1 1]; end
                            property(i) = getProperty('Color',params{1},value);
                            i=i+1; wasColor = 1;
                        elseif (strcmp('X',params{1}) || strcmp('Y',params{1}))
                            property(i) = getProperty('CoordinatesLocked',params{1},get_graphic_param(objGraph,params{1}));
                            i=i+1;               
                        elseif (strcmp('N',params{1}) || strcmp('E',params{1}))
                            %get_graphic_param(saveStructure.graph,params{i})
                            property(i) = getProperty('OtherLocked',params{1},get(objGraph,params{1}));
                            i=i+1;
                        elseif (strcmp('Position',params{1}))
                            %get_graphic_param(saveStructure.graph,params{i})
                            property(i) = getProperty('OtherLocked',params{1},get(objGraph,params{1}));
                            i=i+1;
                        elseif (strcmp('GridFreq',params{1}))
                            %get_graphic_param(saveStructure.graph,params{i})
                            property(i) = getProperty('OtherLocked',params{1},get(objGraph,params{1}));
                            i=i+1;
                        else
                        end
                        params(1) = [];
                    end
                    %assignin('base','p',property);
                    %               end


            case('line')
                edgeStructure = get(varargin{1},'UserData');
  %              if ~isempty(edgeStructure)
                    objEdge = edgeStructure.edge;
                    params = fieldnames(get(objEdge));
                    
                    params{length(params)+1} = 'Color'; params{length(params)+1} = 'X'; params{length(params)+1} = 'Y';
                
                    i = 1; wasColor = 0;
                    while ~isempty(params)
                        if (~isempty(findstr('Name',params{1})) || ~isempty(findstr('Notes',params{1})))
                            if (i == 1)
                                property = getProperty('Text',params(1),get(objEdge,params{1}));
                            else
                                property(i) = getProperty('Text',params(1),get(objEdge,params{1}));
                            end    
                            i=i+1;
                        elseif (~isempty(findstr('User',params{1})))
                            property(i) = getProperty('Text',params{1},get(objEdge,params{1}));
                            i=i+1;
                        elseif (~isempty(findstr('Color',params{1})) && ~wasColor)
                            value = get_graphic_param(objEdge,params{1});
                            if (length(value) ~= 3) value = [0 0 0]; end
                            property(i) = getProperty('Color',params{1},value);
                            i=i+1; wasColor = 1;
                        elseif (~isempty(findstr('X',params{1})) || ~isempty(findstr('Y',params{1})))
                            property(i) = getProperty('CoordinatesLocked',params{1},get_graphic_param(objEdge,params{1}));
                            i=i+1;                  
                        else
%                             get_graphic_param(edge,params{i})
%                             property(i) = getProperty('OtherLocked',params{i},get_graphic_param(objEdge,params{i})); i=i+1;
                        
                        end
                        params(1) = [];
                    end
                    %                end
                
                
            case('rectangle')
                nodeStructure = get(varargin{1},'UserData');
%                if ~isempty(nodeStructure)
                   objNode = nodeStructure.node;
                    params = fieldnames(get(objNode));
                    
                    params{length(params)+1} = 'Color'; params{length(params)+1} = 'X'; params{length(params)+1} = 'Y';
                
                    i = 1; wasColor = 0;
                    while ~isempty(params)
                        if (~isempty(findstr('Name',params{1})) || ~isempty(findstr('Notes',params{1})))
                            if (i == 1)
                                property = getProperty('Text',params(1),get(objNode,params{1})); 
                                i=i+1;
                            else
                                property(i) = getProperty('Text',params(1),get(objNode,params{1})); 
                                i=i+1;
                            end                      
                        elseif (~isempty(findstr('User',params{1})))
                            property(i) = getProperty('Text',params{1},get(objNode,params{1})); 
                            i=i+1;
                            
                        elseif (~isempty(findstr('Color',params{1})) && ~wasColor)
                            value = get_graphic_param(objNode,params{1});
                            if (length(value) ~= 3) value = [1 1 1]; end
                            property(i) = getProperty('Color',params{1},value); 
                            i=i+1; wasColor = 1;
                            
                        elseif (~isempty(findstr('X',params{1})) || ~isempty(findstr('Y',params{1})))
                            property(i) = getProperty('Coordinates',params{1},get_graphic_param(objNode,params{1})); 
                            i=i+1;
                                                    
                        else
%                             get_graphic_param(node,params{i})
%                             property(i) = getProperty('OtherLocked',params{i},get_graphic_param(objNode,params{i})); i=i+1;
                            
                        end
                        params(1) = [];
                    end
                    %               end 
                
        end
        
        return;
    
    end
    
    return;
    
    
    
    
function property = getProperty(type,name,value)
    property = struct('type',{type},'name',{name},'value',{value},'options',{'whatever'});
    return;
    
    