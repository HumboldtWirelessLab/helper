function Out=set(object, varargin)
%SET sets properties to set of objects.
%
%Synopsis
%   SET(OBJECT)
%   SET(OBJECT,'Property')
%   SET(OBJECT,'PropertyName',VALUE)
%   SET(OBJECT,'Property1',Value1,'Property2',Value2,...)
%
%Description
%   SET(OBJECT) displays all properties of OBJECT and their admissible 
%   values. 
%
%   SET(OBJECT,'Property') displays legitimate values for the specified
%   property of OBJECT.
%
%   SET(OBJECT,'PropertyName',PropertyValue) sets the property 'PropertyName' 
%   of the OBJECT to the value PropertyValue.
%
%   SET(OBJECT,'Property1',PropertyValue1,'Property2',PropertyValue2,...) sets multiple 
%   OBJECT property values with a single statement.
%
%   One string have special meaning for PropertyValues:
%      'default' - use default value
%
%   See also SCHEDOBJ/GET.

%   Author(s): M. Kutil, Michal Sojka
%   Copyright (c) 2004 CTU FEE
%   $Revision: 1750 $  $Date: 2007-09-20 11:07:47 +0200 (čt, 20 IX 2007) $

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
 

ni = nargin;
no = nargout;

if ~isa(object,'schedobj'),
    % Call built-in SET. Handles calls like set(gcf,'user',ss)
    builtin('set',object,varargin{:});
    return
elseif no & ni>2,
    error('Output argument allowed only in SET(OBJECT) or SET(OBJECT,Property).');
end

% Get public properties and their assignable values
if ni<=2,
    try
        [AllProps,AsgnValues] = pnames(object,1);
    catch
        [AllProps,AsgnValues] = pnames(object);
    end
else
        [AllProps,AsgnValues,DefValues] = pnames(object);
end

% Handle read-only cases
if ni==1,
    % SET(OBJECT) or S = SET(OBJECT)
    if no,
        Out = cell2struct(AsgnValues,AllProps,1);
    else
        for i=1:length(AllProps)
            disp(sprintf('\t%s%s: %s',blanks(max(cellfun('length',AllProps))-length(AllProps{i})),AllProps{i},AsgnValues{i}))
        end
    end % if no,
    
elseif ni==2,
    % SET(OBJECT,'Property') or STR = SET(OBJECT,'Property')
    % Return admissible property value(s)
    try
        imatch = find(strcmpi(AllProps,varargin{1}));
        if isempty(imatch) && isa(object,'graph')        

        elseif isempty(imatch)
            error('Unknown property.');
        end
        if no,
            Out = AsgnValues{imatch};
        else
            disp(AsgnValues{imatch})
        end
    catch
        rethrow(lasterror)
    end
    
else
    % SET(OBJECT,'Prop1',Value1, ...)
    objectname = inputname(1);
    if isempty(objectname),
        error('First argument to SET must be a named variable.')
    elseif rem(ni-1,2)~=0,
        error('Property/value pairs must come in even number.')
    end % if isempty(objectname),
    
    % Match specified property names against list of public properties and
    % set property values at object level
    for i=1:2:ni-1,
        settedparam=find(strcmpi(AllProps,varargin{i}));
        if settedparam
            % Non-virtual properties are tasnformed to canonical form
            varargin{i} = AllProps{settedparam};
            % and default values are assigned
            if ischar(varargin{i+1})
                if strcmpi(varargin{i+1},'default'), varargin{i+1} = ...
                        DefValues{settedparam};
                end
            end
            % - Node and edge in cell to array
            if isa(varargin{i + 1}, 'cell')
                Value_i = varargin{i + 1};
                for_transfer_node = 0;
                for_transfer_edge = 0;
                for ii=1:length(Value_i)
                    if isa(Value_i{ii}, 'node')
                        for_transfer_node = for_transfer_node + 1;
                    end
                    if isa(Value_i{ii}, 'edge')
                        for_transfer_edge = for_transfer_edge + 1;
                    end
                end
                if (for_transfer_node == length(Value_i)) || (for_transfer_edge == length(Value_i))
                    Value_i = [Value_i{:}];
                    varargin{i + 1} = Value_i;
                end
            end
            % -^
            try
                object = set_helper(object, varargin{i}, varargin{i + 1});
            catch
                try
                    object = setdata(object, varargin{i}, varargin{i + 1});
                catch
                    rethrow(lasterror);
                end
            end
        elseif ~isempty(strmatch('set_vprop',methods(object),'exact')) % Handle virtual properties
            [object, success] = set_vprop(object, varargin{i}, varargin{i + 1});
            if ~success
                error(['Property ' varargin{i} ' can''t be set.']);
            end
        else
            if isa(object,'graph') || isa(schedobj,'node')
                try
                    object = setdata(object, varargin{i}, varargin{i + 1});
                catch
                    rethrow(lasterror);
                end
            else
                error(['Property ' varargin{i} ' can''t be set.']);
            end
        end
    end % for i=1:2:ni-1,

    % Assign object in caller's workspace
    assignin('caller',objectname,object)
end % if ni==1,
% end ... schedobj/set
