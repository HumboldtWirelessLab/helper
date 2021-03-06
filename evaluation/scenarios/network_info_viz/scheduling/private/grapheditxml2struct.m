function out = grapheditxml2struct(pathName, fileName, varargin)
%GRAPHEDITXML2STRUCT converts content of xml file to structure conteins list of plugins. 
%   This file is part of Scheduling Toolbox.
%
%   [pathName filesep fileName] - path of xml file - string
%   out - structure of plugins
%

%   Author: V. Navratil
%   Created in terms of Bachelor project 2006
%   Department of Control Engineering, FEE, CTU Prague, Czech Republic
%

    
    if nargin == 0
        [fileName,pathName] = uigetfile('*.xml','Load xml');
    end
    if isempty(pathName)
        [pathName,mFile] = fileparts(mfilename('fullpath'));
    end
    try
        %xml = xmlread([pathName filesep fileName]);
        xml = xmlread(fileName);
        children = xml.getChildNodes;
        for i = 1:children.getLength
            outStruct(i) = xmlplugins2struct(children.item(i-1));
        end
        out = getpluginlist(outStruct);
    catch
        out = struct('version','','application','','group',[]);
    end

%----------------------------------------------------------------    
    
function s = xmlplugins2struct(node)

    s.name = char(node.getNodeName);
     
    if node.hasAttributes
        attributes = node.getAttributes;
        nattr = attributes.getLength;
        s.attributes = struct('name',cell(1,nattr),'value',cell(1,nattr));
        for i = 1:nattr
            attr = attributes.item(i-1);
            s.attributes(i).name = char(attr.getName);
            s.attributes(i).value = char(attr.getValue);
        end
    else
        s.attributes = [];
    end
    try
        s.data = char(node.getData);
    catch
        s.data = '';
    end
    if node.hasChildNodes
        children = node.getChildNodes;
        nchildren = children.getLength;
        c = cell(1,nchildren);
        s.children = struct('name',c,'attributes',c,'data',c,'children',c);
        for i = 1:nchildren
            child = children.item(i-1);
            s.children(i) = xmlplugins2struct(child);
        end
    else
        s.children = [];
    end 
   
%----------------------------------------------------------------    
    
function out = getpluginlist(in)
    out = struct('version','','application','','group',[]);
    out.application = getparam(in.attributes,'application');
    out.version = getparam(in.attributes,'ver');
    for i = 1:length(in.children)
        switch lower(in.children(i).name)
            case 'group'
                if isempty(out.group)
                    out.group = getgroup(in.children(i));
                else
                    out.group(length(out.group)+1) = getgroup(in.children(i));
                end
            otherwise
        end
    end
    
%----------------------------------------------------------------  

function out = getgroup(in)
    out = struct('name','','description','','plugin',[]);
    out.name = getparam(in.attributes,'name');
    for i = 1:length(in.children)
        switch lower(in.children(i).name)
            case 'description'
                if ~isempty(in.children(i).children)
                    out.description = in.children(i).children.data;
                else
                    out.description = '';
                end
            case 'plugin'
                if isempty(out.plugin)
                    out.plugin = getplugin(in.children(i));
                else
                    out.plugin(length(out.plugin)+1) = getplugin(in.children(i));
                end
            otherwise
        end
    end  

%----------------------------------------------------------------    
    
function out = getplugin(in)
    out = struct('name','','gui','','description','','command','');
    out.name = getparam(in.attributes,'name');
    out.gui = getparam(in.attributes,'gui');
    for i = 1:length(in.children)
        switch lower(in.children(i).name)
            case 'description'
                if ~isempty(in.children(i).children)
                    out.description = in.children(i).children.data;
                end
                %out.description = sprintf([out.description '\n']);
            case 'command'
                out.command = in.children(i).children.data;
            otherwise
        end
    end
    
%----------------------------------------------------------------    

function out = getparam(in,param)
    for i = 1:length(in)
        switch lower(in(i).name)
            case param
                out = in(i).value;
            otherwise
        end
    end
    
%----------------------------------------------------------------    

