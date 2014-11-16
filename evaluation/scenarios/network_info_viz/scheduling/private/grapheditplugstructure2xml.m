function saved = grapheditplugstructure2xml(pluginlist, pluginFileName)
%GRAPHEDITPLUGSTRUCT2XML converts structure conteins list of plugins to xml file. 
%   This file is part of Scheduling Toolbox.
%
%   pluginlist - plugins structure - struct
%   pluginFileName - name of xml file - string
%   saved - 1 is saved, 0 is not saved - int
%

%   Author: V. Navratil
%   Created in terms of Bachelor project 2006
%   Department of Control Engineering, FEE, CTU Prague, Czech Republic
%


    %assignin('base','p',pluginlist)
    saved = 1;
    try
        [pathGraphEdit,command,ext,ver] = fileparts(mfilename('fullpath'));
        savexml([pathGraphEdit filesep],pluginFileName,pluginlist);
    catch
        saved = 0;
    end
    


function savexml(pathname, filename, pluginlist, varargin)

    if nargin == 0
        [filename,pathname] = uiputfile('*.xml','Save graph');
    end

    if ~isempty(filename) && ~isempty(pluginlist)
          
        docNode = com.mathworks.xml.XMLUtils.createDocument('pluginlist');
        
        docRootNode = docNode.getDocumentElement;
        docRootNode.setAttribute('application','Graphedit');
        docRootNode.setAttribute('ver',pluginlist.version);
        
        for i = 1:length(pluginlist.group)
            thisElement = docNode.createElement('group');
            docGroupNode = docRootNode.appendChild(thisElement);
            docGroupNode.setAttribute('name',pluginlist.group(i).name);
            
            thisElement = docNode.createElement('description');
            thisElement.appendChild(docNode.createTextNode(pluginlist.group(i).description));
            docGroupNode.appendChild(thisElement);
            
            for j = 1:length(pluginlist.group(i).plugin)
                thisElement = docNode.createElement('plugin');
                docPluginNode = docRootNode.appendChild(thisElement);
                docPluginNode.setAttribute('name',pluginlist.group(i).plugin(j).name);
                docPluginNode.setAttribute('gui',pluginlist.group(i).plugin(j).gui);
                docGroupNode.appendChild(thisElement);
                
                if ~isempty(pluginlist.group(i).plugin(j).description)
                    thisElement = docNode.createElement('description');
                    thisElement.appendChild(docNode.createTextNode(pluginlist.group(i).plugin(j).description));
                    docPluginNode.appendChild(thisElement);
                end
                
                thisElement = docNode.createElement('command');
                thisElement.appendChild(docNode.createTextNode(pluginlist.group(i).plugin(j).command));
                docPluginNode.appendChild(thisElement);
            end
        end
        % Save the XML document.
        [path,name,ext] = fileparts(filename);
        xmlFileName = filename;
        xmlwrite(xmlFileName,docNode);
    end
