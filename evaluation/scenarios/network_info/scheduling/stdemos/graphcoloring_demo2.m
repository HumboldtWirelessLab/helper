% GRAPHCOLORING_DEMO2 Demo application of the graph coloring
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


close(graphedit);

picturePath = [fileparts(mfilename('fullpath')) filesep];
cDataClean = imread([picturePath 'czech_regions.png']);
cDataColor = imread([picturePath 'czech_regions_colored.png']);
[height,width,colors] = size(cDataClean);
monitor = get(0,'ScreenSize');
graphedit('position',[(monitor(3)-width)/2, (monitor(4)-height)/2 width height],...
          'hideparts','all','viewnodesnames','off','propertyeditor','off')

%======================================================================

% Slide 1
graphedit('importbackground',cDataClean,'fitbackground','width')

% Slide 2
g = graph('adj',zeros(14));
graphedit(g,'importbackground',cDataClean,'fitbackground','width','viewtab',1)

% Slide 3
x = [124;  66; 189; 338; 328; 424; 479; 579; 692; 650; 527; 272; 414; 264];
y = [198; 301; 358; 401; 288; 344; 253; 215; 246; 137; 107; 286; 168;  93];
for i = 1:length(g.N),
    g.N(i).GraphicParam{1}.x = x(i);
    g.N(i).GraphicParam{1}.y = y(i);
end
graphedit(g,'importbackground',cDataClean,'fitbackground','width','viewtab',1)

% Slide 4
edgeList = {1,2; 1,3; 1,5; 1,14; 2,3; 3,4; 3,5; 4,5; 4,6; 5,6; 5,7;...
            5,13; 5,14; 5,12; 6,7; 7,8; 7,11; 7,13; 8,9; 8,10; 8,11;...
            9,10; 10,11; 11,13; 11,14; 13,14};
g = graph(g,'edl',edgeList);
graphedit(g,'importbackground',cDataClean,'fitbackground','width','viewtab',1)

% Slide 5
g = graphcoloring(g);
graphedit(g,'importbackground',cDataClean,'fitbackground','width','viewtab',1)

% Slide 6
graphedit(g,'importbackground',cDataColor,'fitbackground','width','viewtab',1)

% Slide 7
graphedit('createtab',[],'importbackground',cDataColor,'fitbackground','width','viewtab',1)

%======================================================================

% Slideshow
for i = 1:7,
    graphedit('viewtab',i); pause(2.0);
end
for i = 1:4,
    graphedit('viewtab',1); pause(0.5);
    graphedit('viewtab',7); pause(0.5);
end

%end of file
