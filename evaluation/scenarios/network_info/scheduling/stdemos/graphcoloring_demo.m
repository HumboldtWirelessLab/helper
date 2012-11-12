% GRAPHCOLORING_DEMO Demo application of the graph coloring
%
%    See also GRAPHCOLORING

%   Author(s): V. Navratil, P.Sucha
%   Copyright (c) 2005 CTU FEE
%   $Revision: 1896 $  $Date: 2007-10-12 08:13:54 +0200 (pá, 12 X 2007) $

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


clc;
disp('Demo of graph coloring algorithm.');
disp('-------------------------------------------');


A = [0 1 1 0 0 0 0;
    0 0 0 1 1 0 0;
    0 0 0 0 0 1 1;
    0 0 0 0 0 0 0;
    1 0 0 1 0 0 0;
    1 0 0 0 1 0 1;
    0 0 0 0 1 0 0];
g3 = graph('adj',A);
g3.Name = 'G_{2}';
g4 = graphcoloring(g3);
g4.Name = 'G_{2} - Colored';

graphedit(g3,g4);

%end of file

