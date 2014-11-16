function out = color2rgb (color)
%ISCOLOR converts color name to the RGB equivalent.
%    ISCOLOR(C) returns RGB triple equivalent to predefined color name C
%    in long format {'yellow','magenta','cyan','red','green','blue',
%    'white','black'} or short format {'y','m','c','r','g','b','w','k'}.
%  
%     See also ISCOLOR

%   Author(s): P. Sucha
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
 
colorLongName={'yellow','magenta','cyan','red','green','blue','white','black'};
colorShortName={'y','m','c','r','g','b','w','k'};
colorRGB={[1 1 0],[1 0 1],[0 1 1],[1 0 0],[0 1 0],[0 0 1],[1 1 1],[0 0 0]};

switch(iscolor(color))
    case 1
        out = color;
    case 2
        [tf loc]=ismember(color,colorLongName);
        out = colorRGB{loc};
    case 3
        [tf loc]=ismember(color,colorShortName);
        out = colorRGB{loc};
    otherwise
        error('Input parameter ''color'' is not valid color.');
end;

%end .. color2rgb
