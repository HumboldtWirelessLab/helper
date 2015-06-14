function TS = setprio_rm(TS)
%SETPRIO_RM Implements rate monotonic priority assignment.
% 
%   See also SETPRIO.

%   Author(s):  Michal Sojka
%   Copyright (c) 2004 CTU FEE
%   $Revision: 81 $  $Date: 2004-11-15 12:37:02 +0100 (po, 15 XI 2004) $

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
    per = get(TS, 'Period');
catch
    error('This is applicable only for taskset with periodic task(s).');
end

[a ind] = sort(per);
for i=1:length(ind)
    j = ind(i);
    if per(j) ~= NaN
        TS.tasks{j} = set_helper(TS.tasks{j}, 'Weight', length(ind)-i+1);
        TS.tasks{j};
    end % if prio(j) ~= NaN
end % for i=1:length(ind)
