function task = add_scht (task, start, length, processor)
%ADD_SCHT adds schedule (starts time and lenght of time) into a task
%
%Synopsis
% Tout = ADD_SCHT(Tin, start, lenght[, processor])
%
%Description
% Properties:
%  Tout:
%    - new task with schedule
%  Tin:
%    - task without schedule
%  start:
%    - array of start time
%  lenght:
%    - array of length of time
%  processor:
%    - array of number of processor
%
% See also TASK/GET_SCHT

%   Author(s):  M. Kutil
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
 

task.schStart = start;
task.schLength = length;
if (exist('processor', 'var'))
    task.schProcessor = processor;
end

%end .. @task/add_scht
