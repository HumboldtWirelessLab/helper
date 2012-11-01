function display(T)
%DISPLAY   Display task
%
% Syntax
%    DISPLAY(T)

%   Author(s):  M. Kutil
%   Copyright (c) 2004 CTU FEE
%   $Revision: 1380 $  $Date: 2007-06-27 14:02:27 +0200 (st, 27 VI 2007) $

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
 
reducename = schfeval('private/tex2mtex',T.Name);
if strcmp(reducename, T.Name)
    quote = '""';
else
    quote = '»«';
end
disp(['Task ' quote(1) reducename quote(2)]);
disp([' Processing time: ',int2str(T.ProcTime)]);
disp([' Release time:    ',int2str(T.ReleaseTime)]);

if (T.Deadline < inf)
    if (T.Deadline<(T.ProcTime+T.ReleaseTime))
        war='  warning: Deadline is too early!';
    else
        war='';
    end   
    disp([' Deadline:        ',int2str(T.Deadline),war]);
end;

if (T.DueDate < inf)
    if (T.DueDate>T.Deadline)
        war='  warning: Due date is larger than deadline!';
    else
        war='';
    end   
    disp([' Due date:        ',int2str(T.DueDate),war]);
end
if (T.Weight ~= 1)
    disp([' Weight:          ',int2str(T.Weight)]);
end
if (length(T.Processor) ~= 0)
    disp([' Processor:       ',int2str(T.Processor)]);
end

%end .. @task/display
