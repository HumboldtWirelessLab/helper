function configuration = grapheditxml2configuration(configurationFileName,defaultConfiguration)
%GRAPHEDITXML2CONFIGURATION converts xml file to structure conteins
%configuraton of graphedit. 
%
%   This file is part of Scheduling Toolbox.
%

%   Author: V. Navratil
%   Created in terms of Bachelor project 2006
%   Department of Control Engineering, FEE, CTU Prague, Czech Republic


    try
        xml = xmlread(configurationFileName);
        children = xml.getChildNodes;
        for i = 1:children.getLength
            outStruct(i) = xmlplugins2struct(children.item(i-1));
        end
        configuration = transformstructure(outStruct.children);
        configuration = testofconfiguration(configuration,defaultConfiguration,configurationFileName);
    catch
        configuration = defaultConfiguration;
    end

%=========================================================================

function s = xmlplugins2struct(node)
    s.name = char(node.getNodeName);
    if node.hasAttributes
        attributes = node.getAttributes;
        nattr = attributes.getLength;
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
    end
    if node.hasChildNodes
        children = node.getChildNodes;
        nchildren = children.getLength;
        s.children = [];
        for i = 1:nchildren
            child = children.item(i-1);
            struct = xmlplugins2struct(child);
            s.children{end+1} = struct;
        end
    else
        s.children = []; 
    end 

%=========================================================================

function configuration = transformstructure(inputCell)
    for i = 1:length(inputCell),
        if iscell(inputCell),
            thisStruct = inputCell{i};
        else
            thisStruct = inputCell;
        end
        if ~strcmp(thisStruct.name,'#text'),
            value = retype(thisStruct.attributes(end).value,thisStruct.children{1}.data);
            if strcmp(thisStruct.attributes(end).value,'struct'),
                value = transformstructure(thisStruct.children); %#ok<NASGU>
            elseif strcmp(thisStruct.attributes.value,'cell'),
                value{str2double(thisStruct.children{2}.attributes(1).value)} = transformstructure(thisStruct.children{2});
                value{1} = value{1}.cell;
            end
            eval(['configuration.' thisStruct.name ' = value;']);
        end
    end

%=========================================================================

function value = retype(type,string)
    switch type
        case 'char'
            value = string;
        case 'struct'
            value = [];
        case {'double','int','int16','int08'}
            value = str2num(string);
        case 'cell'
            value = [];
        case 'logical'
            value = logical(str2double(string));
        otherwise
            error('Invalid data type.');
    end
    
%=========================================================================

function configuration = testofconfiguration(configuration,defaultConfiguration,configurationFileName)
    [configuration,replaced,save] = dotest(configuration,defaultConfiguration,'',false);
    if ~isempty(replaced),
        h = warndlg(['Invalid data types in configuration xml file have appeared. The values ' replaced(3:end) ' were replaced by default ones.']);
        set(h,'WindowStyle','modal');
    end
    if save,
        grapheditconfiguration2xml(configuration,configurationFileName);
    end

%=========================================================================

function [configuration,replaced,save] = dotest(configuration,defaultConfiguration,replaced,save)
    defConfNames = fieldnames(defaultConfiguration);
    for i = 1:length(defConfNames),
        if isfield(configuration,defConfNames{i})
            value = eval(['configuration.' defConfNames{i}]);
            if isstruct(value),
                [newValue,replaced,save] = dotest(value,eval(['defaultConfiguration.' defConfNames{i}]),replaced,save);
                eval(['configuration.' defConfNames{i} ' = newValue;']);
            elseif iscell(value),
%                 for j = 1:length(value),
%                     [newValue,replaced,save] = dotest(value{j},eval(['defaultConfiguration.' defConfNames{i} '{j}']),replaced,save);
%                     eval(['configuration.' defConfNames{i} '{j} = newValue;']);
%                 end
            else
                if ~isa(value,class(eval(['defaultConfiguration.' defConfNames{i}]))),
                    replaced = [replaced, ', ''' defConfNames{i} ''''];
                    eval(['configuration.' defConfNames{i},...
                          ' = defaultConfiguration.' defConfNames{i} ';']);
                    save = true;
                end
            end
        else
            eval(['configuration.' defConfNames{i},...
                  ' = defaultConfiguration.' defConfNames{i} ';']);
            save = true;
        end
    end
    
%=========================================================================
%=========================================================================
