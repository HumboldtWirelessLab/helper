function [Value, found] = get_vprop(taskset,Property)
%GET_VPROP  Access/query TASKSET virtual property values.
%
%   VALUE = GET_VPROP(TASKSET,'VirtualPropertyName') returns the value
%   of the specified virtual property of the TASKSET.
% 
%   NOTE: This function is for internal use only. Use GET instead.
%   
%   See also GET.

%   Author(s): M. Kutil, Michal Sojka
%   Copyright (c) 2004 CTU FEE
%   $Revision: 727 $  $Date: 2007-03-13 16:34:55 +0100 (út, 13 III 2007) $

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
 

found = true;
switch lower(Property)
  case 'scheduledesc'  % lower case
    Value = taskset.schedule.desc;
    return;
  case 'count'  % lower case
    Value = size(taskset);
    return;
  case 'tasks'  % lower case
    Value = taskset.tasks;
    return;   
end
    
% Try to collect properties of all tasks
found = false;
Value = [];
outputDimension = 0;
for i=1:size(taskset.tasks, 1)
    for j=1:size(taskset.tasks, 2)
        try
            V = get(taskset.tasks{i,j}, Property);
            found = true;
        catch
            V = NaN;
        end
        if ischar(V)
            Value{i,j} = V;
        elseif isempty(V)
            Value(i,j) = NaN;
        else
            if (size(taskset.tasks, 1) == 1) % Klasikl taskset with 1xn task
                if (size(V,1) == 1) & (size(V,2) > 1) & (outputDimension == size(V,2) | outputDimension == 0) % Multi parameter
                    Value(:,j) = V';
                    outputDimension = size(V,2);
                elseif (length(V)==1) & (outputDimension == size(V,2) | outputDimension == 0)
                    Value(i,j) = V;
                    outputDimension = 1;
                else
                    error(['Dimension mismatch in ' Property ' property.']);
                end
            else %Prepare for Shops
                error(['Remove this error message from get_vprop.m file, this is for Shops']);
                Value(i,j) = V;
            end
        end
    end
end


% *************
% funtion for get properties from task
function prop = get_prop(taskset,property)
for i=1:1:size(taskset.tasks,2)
    tmp = get(taskset.tasks(i),property);
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
