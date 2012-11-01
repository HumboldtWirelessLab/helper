function out = iscolor (color)
%ISCOLOR True for valid color.
%    ISCOLOR(C) returns 1 if C is RGB Value, 2 if C is long name, 3 for
%               short name and 0 otherwise.
%  
%     See also to documentation >>doc ColorSpec

%   Author(s): M. Kutil
%   Copyright (c) 2005 CTU FEE
%   $Revision: 714 $  $Date: 2007-03-12 10:31:40 +0100 (po, 12 III 2007) $

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
 
out = 0;
if isnumeric(color) 
    if (size(color) == [1 3]) 
        if (color <= 1) & (color >= 0)
            out = 1;
        end
    end
elseif ischar(color)
    if sum(strcmpi(color,{'yellow','magenta','cyan','red','green','blue','white','black'}))
        out = 2;
    elseif sum(strcmpi(color,{'y','m','c','r','g','b','w','k'}))
        out = 3;
    end
end
%end .. iscolor