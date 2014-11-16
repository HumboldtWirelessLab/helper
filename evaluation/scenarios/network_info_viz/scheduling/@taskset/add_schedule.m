function add_schedule (TASKSET, varargin)
%ADD_SCHEDULE adds schedule (starts time and lenght of time) for set of
%  tasks 
%
%Synopsis
% ADD_SCHEDULE(T, description[, start, length[, processor]])
% ADD_SCHEDULE(T, keyword1, param1, ..., keywordn, paramn)
%
%Description
% Properties:
%  T:
%   - taskset; schedule will be save into this taskset.
%  description:
%   - description for schedule. It must be diferent than a key words below!
%  start:
%   - set of start time
%  lenght:
%   - set of lenght of time
%  processor:
%   - set of number of processor
%  keyword:
%   - key word (char)
%  param:
%   - parameter
%
% Available key words are:
%   description:
%     - schedule description (it is same as above)
%   time:
%     - calculation time for search schedule
%   iteration:
%     - number of interations for search schedule
%   memory:
%     - memory allocation during schedule search
%   period:
%     - taskset period - scalar or vector for diferent period of each task
%
% See also TASKSET/GET_SCHEDULE

%   Author(s):  M. Kutil
%   Copyright (c) 2004 CTU FEE
%   $Revision: 1762 $  $Date: 2007-09-20 15:06:13 +0200 (čt, 20 IX 2007) $

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

ni = nargin-1;

TASKSET.schedule.is = 1;

if sum(strcmpi(varargin{1},{'description', 'time', 'iteration', 'memory', 'period'})) >= 1
    % Add param about schedule
    if mod(ni,2)
        error('Incorrect parameters number!');
    end
    for i = 1:2:ni
        switch lower(varargin{i})
            case 'description'
                TASKSET.schedule.desc = varargin{i+1};
            case 'time'
                TASKSET.schedule.time = varargin{i+1};
            case 'iteration'
                TASKSET.schedule.iterations = varargin{i+1};
            case 'memory'
                TASKSET.schedule.memory = varargin{i+1};
			case 'period'
				period = varargin{i+1};
				if length(period) == 1
					period(1:count(TASKSET)) = period;
				end
				for i=1:min(length(period),count(TASKSET))
					taskforperiod = TASKSET.tasks{i};
					taskforperiod=set_helper(taskforperiod,'schPeriod',period(i));
					TASKSET.tasks{i} = taskforperiod;
				end
            otherwise
                error('Unknow key word!');
        end
    end
else
    % Add schedule
    TASKSET.schedule.desc = varargin{1};

    if ni >= 3
        start = varargin{2};
        if  isa(start,'double')
            start = num2cell(varargin{2});
        end
        lenght = varargin{3};
        if isa(lenght,'double')
            lenght = num2cell(varargin{3});
        end

        if ni >= 4
            procesor = varargin{4};
            if isa(procesor,'double')
                procesor = num2cell(varargin{4});
            end          
        end
        for i=1:size(start,2)
            if exist('procesor','var'),
                procesor_for_task = procesor{i};
            else
                procesor_for_task = 1;
            end
            TASKSET.tasks{i}=add_scht(TASKSET.tasks{i},start{i},lenght{i},procesor_for_task);
        end
    end
end

% Assign TS in caller's workspace
snname = inputname(1);
assignin('caller',snname,TASKSET)

%end .. @taskset/add_schedule
