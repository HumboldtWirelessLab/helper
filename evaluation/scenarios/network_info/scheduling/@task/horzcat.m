function setoftasks = horzcat(varargin)
%HORZCAT      Creates a TaskSet from tasks
%                   Tasks = [T1 T2 T3 ... ]
%  See also TASKSET.

%   Author(s): M. Kutil
%   Copyright (c) 2004 CTU FEE
%   $Revision: 119 $  $Date: 2005-05-16 08:56:08 +0200 (po, 16 V 2005) $

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
 
try
    setoftasks = taskset(varargin);
catch
    rethrow(lasterror)
end
%end .. @task/horzcat
