function [sch_start, sch_length, sch_processor, is_schedule] = get_schedule (TS)
%GET_SCHEDULE gets schedule (starts time, lenght of time and processor)
%  from a taskset 
%
%Synopsis
%  [start, lenght, processor, is_schedule] = GET_SCHEDULE(T)
%
%Description
% Properties:
%  T:
%    - taskset
%  start:
%    - cell/array of start times
%  lenght:
%    - cell/array of lengths of time
%  processor:
%    - cell/array of numbers of processor
%  is_schedule:
%    - 1 - schedule is inside taskset
%    - 0 - taskset without schedule
%
% See also TASKSET/ADD_SCHEDULE.

%   Author(s):  M. Kutil
%   Copyright (c) 2004 CTU FEE
%   $Revision: 1851 $  $Date: 2007-09-27 06:36:22 +0200 (čt, 27 IX 2007) $

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

is_schedule = TS.schedule.is;
if (is_schedule)
    for i=1:count(TS)
        [sch_start{i} sch_length{i} sch_processor{i}]= get_scht(TS.tasks{i});
    end
    % cell to array
    maxlength = 0;
    for i=1:count(TS)
        maxlength = max([maxlength length(sch_start{i}) length(sch_length{i}) length(sch_processor{i})]);
    end
    if maxlength == 1
        sch_start = cell2mat(sch_start);
        sch_length = cell2mat(sch_length);
        sch_processor = cell2mat(sch_processor);
    end 
else
    sch_start = nan;
    sch_length = nan;
    sch_processor = nan;
end
%end .. @taskset/get_schedule
