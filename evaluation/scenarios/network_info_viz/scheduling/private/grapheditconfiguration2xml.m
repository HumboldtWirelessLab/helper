function grapheditconfiguration2xml(struct,filename)
%GRAPHEDITCONFIGURATION2XML converts configuration structure to xml and
%save it as file filename.
%
%     See also grapheditplugstructure2xml

%   Author(s): V. Navratil
%   Copyright (c) 2005
%   $Revision: 1896 $  $Date: 2007-10-12 08:13:54 +0200 (pá, 12 X 2007) $

    try
        docNode = com.mathworks.xml.XMLUtils.createDocument('configuration');
        docRootNode = docNode.getDocumentElement;
        docRootNode.setAttribute('application','Graphedit');
        docRootNode.setAttribute('ver',struct.version);
        docRootNode = struct2xml(docNode,docRootNode,struct);

        emptyfn = 0;
        if (isempty(filename))
            emptyfn = 1;
            filename = [tempname,'.xml'];
        end
        xmlwrite(filename,docRootNode);
        if (emptyfn)
            edit(filename);
        end
    catch
        rethrow(lasterror);
    end
        
%=========================================================================

function docRootNode = struct2xml(docNode,docRootNode,struct)
    names = fieldnames(struct);
    for i = 1:length(names),
        data = eval(['struct.' names{i}]);
        thisElement = docNode.createElement(names{i});
%         thisElement.setAttribute('name',names{i});
        thisElement = setchildren(docNode,thisElement,data);
        docRootNode.appendChild(thisElement);   
    end

%=========================================================================

function thisElement = setchildren(docNode,thisElement,data)
    if isstruct(data),
        thisElement.setAttribute('type','struct');
        thisElement = struct2xml(docNode,thisElement,data);
    elseif ischar(data),
        thisElement.setAttribute('type','char');
        thisElement.appendChild(docNode.createTextNode(data));
    elseif isnumeric(data),
        thisElement.setAttribute('type',class(data));
        thisElement.appendChild(docNode.createTextNode(num2str(data)));
    elseif iscell(data),
        thisElement.setAttribute('type','cell');
        thisElement = cell2xml(docNode,thisElement,data);
    elseif islogical(data),
        thisElement.setAttribute('type','logical');
        thisElement.appendChild(docNode.createTextNode(logical2str(data)));
    else
        error ('Invalid data structure!');
    end

%=========================================================================

function strVariable = logical2str(variable)
    if variable,
        strVariable = '1';
    else
        strVariable = '0';
    end
    
%=========================================================================

function docRootNode = cell2xml(docNode,docRootNode,data)
    for i = 1:length(data),
        thisElement = docNode.createElement('cell');
        thisElement.setAttribute('number',num2str(i));
        thisElement = setchildren(docNode,thisElement,data{i});
        docRootNode.appendChild(thisElement);   
    end

%=========================================================================    