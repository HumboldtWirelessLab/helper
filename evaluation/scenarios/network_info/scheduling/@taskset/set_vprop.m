function [TaskSet, Success] = set_vprop(TaskSet,Property,Value)
%SET_VPROP Set TASKSET virtual property values.
%
%   [TASKSET, SUCCESS] = SET_VPROP(TASKSET,PROPERTY,VALUE) sets the
%   value of the specified virtual property to a VALUE.
% 
%   NOTE: This function is for internal use only. Use SET instead.
%   
%   See also SET.

%   Author(s): Michal Sojka
%   Copyright (c) 2004 CTU FEE
%   $Revision: 170 $  $Date: 2005-07-04 08:57:15 +0200 (po, 04 VII 2005) $

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
 

Success = true;
switch lower(Property)
  case 'schedule_desc'  % lower case
    TaskSet.schedule.desc = Value;
    return;
  case 'tasks'  % lower case
    if (iscell(Value))
        for i=1:length(Value)
            if (~isa(Value{i},'task')) error ('Invalid data type!');end;
        end
        TaskSet.tasks = Value; %valid that it is class tasks
    elseif isa(Value,'task')
        TaskSet.tasks = {Value};
    else
        error ('Invalid data type!');
    end
    return;
end
    
% Try to set properties of all tasks
Success = false;
if any(size(TaskSet.tasks) ~= size(Value))
    error('Value has different size than Tasks');
end
for i=1:size(TaskSet.tasks, 1)
    for j=1:size(TaskSet.tasks, 2)
        try
            if iscell(Value)
                TaskSet.tasks{i,j} = set_helper(TaskSet.tasks{i,j}, Property, Value{i, j});
            else
                TaskSet.tasks{i,j} = set_helper(TaskSet.tasks{i,j}, Property, Value(i, j));
            end
            Success = true;
        catch
            % Not every task must have this property
        end
    end
end


% *************
% funtion for get properties from task
function prop = get_prop(TaskSet,property)
for i=1:1:size(TaskSet.tasks,2)
    tmp = get(TaskSet.tasks(i),property);
    if sum(strcmpi(property,{'name','machine'}))
        prop{i} = tmp;
    else
        prop(i) = tmp;
    end
end
%end .. get_prop

% *************
% funtion for remove non public property
function val = rm_field(val,AllProps)
prop = fieldnames(val);
for i=1:length(prop),
    if ~sum(strcmpi(AllProps,prop{i}))
        val = rmfield(val,prop{i});
    end
end
%end .. rm_field

%end .. @task/get
