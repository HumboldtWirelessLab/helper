function taskout = loadobj(taskin)
%LOADOBJ loadobj for task class

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
 
if isa(taskin,'task')
    taskout = taskin;
else %taskin is ol version
    switch taskin.version
        case 0.02
            taskin.UserParam = [];
            taskin.ALAP = [];           
            taskin.ASAP = [];
        case 0.03
            taskin.ALAP = [];           
            taskin.ASAP = [];
            taskin.schPeriod = [];			
		otherwise
            error('Wrong version');
            return;
    end
    taskin.version = 0.04;
    schedobj_back=taskin.schedobj;
    taskin = rmfield(taskin,'schedobj'); 
    parent = schedobj;
    taskout = class(taskin,'task', parent);
    taskout.schedobj = schedobj_back;
end
%end .. @task/loadobj
