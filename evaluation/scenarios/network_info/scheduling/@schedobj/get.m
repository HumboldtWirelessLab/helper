function Value = get(schedobj,Property)
%GET access/query SCHEDOBJ property values.
%
%Synopsis
%           GET(SCHEDOBJ)
%           GET(SCHEDOBJ,'PropertyName')
%   VALUE = GET(...)
%
%Description
%   GET(SCHEDOBJ,'PropertyName') returns the value of the specified
%   property of the SCHEDOBJ. 
%
%   GET(SCHEDOBJ) displays all properties of SCHEDOBJ and their values.  
%
% See also SCHEDOBJ/SET.

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
error(nargchk(1,2,ni));

% Get all public properties
AllProps = pnames(schedobj);


if ni==2,
    % GET(SCHEDOBJ,'Property') or GET(SCHEDOBJ,{'Prop1','Prop2',...})
    CharProp = ischar(Property);
    if CharProp,
        Property = {Property};
    elseif ~iscellstr(Property)
        error('Property name must be a string or a cell vector of strings.')
    end
    
    % Loop over each queried property 
    Nq = prod(size(Property)); 
    Value = cell(1,Nq);
    s = struct(schedobj);
    for i=1:Nq,
        % Find match for k-th property name and get corresponding
        % value
        try 
            Value{i} = getfield(s,AllProps{find(strcmpi(AllProps,Property{i}))});
            if (~isempty(strmatch('get_correction',methods(schedobj),'exact')))
                Value{i} = get_correction(schedobj,Property{i},Value{i});
            end            
            if isa(Value{i}, 'node') || isa(Value{i}, 'edge')
                Value_i = Value{i};
                for ii=1:length(Value_i)
                    Value_tmp{ii}=Value_i(ii);
                end
                Value{i} = Value_tmp;
            end
        catch    
            if isfield(s, 'parent')
                try
                    Value{i} = get(getfield(s, s.parent), Property{i});
                    found = 1;
                catch
                    found = 0;
                end
            else
                found = 0;
            end
            
            if ~found & ~isempty(strmatch('get_vprop',methods(schedobj),'exact'))
                [Value{i} found] = get_vprop(schedobj, Property{i});
            end
            if ~found
                if isa(schedobj,'graph') || isa(schedobj,'node')
                    try
                        Value{i} = getdata(schedobj,Property{i});
                    catch
                        rethrow(lasterror);
                    end
                else
                    error('Property %s isn''t available!', Property{i});
                end
            end
        end
    end
    
    % Strip cell header if PROPERTY was a string
    if CharProp,
        Value = Value{1};
    end

elseif nargout,
    % STRUCT = GET(SCHEDOBJ)
    Value = get_props(schedobj);
else
    % GET(SCHEDOBJ)
    print_props(schedobj);
end

% TODO: Proposition: How to make GET and SET quicker? Extend pnames
% that in also returns the location of particular property
% e.g. task.schedobj.notes. This value will be cached in a objects
% field and GET and SET will use these values instead of doing
% recursive descent.

%end .. @schedobj/get
