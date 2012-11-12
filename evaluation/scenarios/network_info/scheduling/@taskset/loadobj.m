function tasksetout = loadobj(tasksetin)
%LOADOBJ loadobj for taskset class

%   Author(s): M. Kutil
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
 
last_version = 0.3;

if isa(tasksetin,'taskset')
    tasksetout = tasksetin;
    %tasksetin is old version (uncrash changes)
    switch tasksetin.Version
        case 0.2
            schedule_struct = schstruct; %schedule struct
            old_struct = tasksetin.schedule;
            items_in=fieldnames(old_struct);
            for i = 1:length(items_in)
                schedule_struct=setfield(schedule_struct,items_in{i},getfield(old_struct,items_in{i}));
            end
            tasksetout.schedule = schedule_struct;
    end
    tasksetout.Version = last_version;
    
else %tasksetin is old version
    switch tasksetin.Version
        case 0.1
            tasksetin.TSUserParam = [];
            
            schedule_struct = schstruct; %schedule struct
            old_struct = tasksetin.schedule;
            items_in=fieldnames(old_struct);
            for i = 1:length(items_in)
                schedule_struct=setfield(schedule_struct,items_in{i},getfield(old_struct,items_in{i}));
            end
            tasksetin.schedule = schedule_struct;
            
        otherwise
            error('Wrong version');
            return;
    end
    tasksetin.Version = last_version;
    schedobj_back=tasksetin.schedobj;
    tasksetin = rmfield(tasksetin,'schedobj'); 
    parent = schedobj;
    tasksetout = class(tasksetin,'taskset', parent);
    tasksetout.schedobj = schedobj_back;
end
%end .. @taskset/loadobj
