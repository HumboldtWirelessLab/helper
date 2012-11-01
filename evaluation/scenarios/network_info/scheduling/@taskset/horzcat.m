function setoftasks = horzcat(varargin)
%HORZCAT      Concatenation of taskset.
%                   Taskset = [T1 T2 T3 ... ]
%
%  Notice: Schedule is not cleared from tasks
%
%  See also TASKSET.

%   Author(s): M. Kutil
%   Copyright (c) CTU FEE
%   $Revision: 123 $  $Date: 2005-05-25 09:00:57 +0200 (st, 25 V 2005) $

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
if isa(varargin{1},'task')
    setoftasks = [varargin{1}];
elseif  isa(varargin{1},'taskset')
    setoftasks = varargin{1};
end
for i = 2:ni
    if isa(varargin{i},'task')
        addto = [varargin{i}];
    elseif  isa(varargin{i},'taskset')
        addto = varargin{i};
    end
    setoftasks.Prec = blkdiag(get(setoftasks,'Prec'), get(addto,'Prec')); % Must be use function GET - get_cerrection() function will be call!
    setoftasks.tasks = {setoftasks.tasks{:} addto.tasks{:}};
    if ~isempty(setoftasks.schedule.desc) & ~isempty(addto.schedule.desc) 
        conjunction = ' | ';
    else
        conjunction = '';
    end
    setoftasks.schedule.desc = [setoftasks.schedule.desc conjunction addto.schedule.desc];
    setoftasks.schedule.is = setoftasks.schedule.is | addto.schedule.is;
end
%end .. @taskset/horzcat