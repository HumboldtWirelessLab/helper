function display(E)
%DISPLAY   Display edge
%
% Syntax
%    DISPLAY(E)

%   Author(s):  M. Kutil
%   Copyright (c) 2004 CTU FEE
%   $Revision: 106 $  $Date: 2005-05-04 16:15:26 +0200 (st, 04 V 2005) $

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
 
if length(E) > 1
    disp (['Set of ', int2str(length(E)), ' edges']);
else
    disp(['Edge "',E.Name,'"']);
end
%end .. @edge/display
