function ge_move_edge(handle,x,y,r)
%GE_MOVE_EDGE  moves created edge
%    ge_move_edge(HANDLE,X,Y,R)
%      HANDLE   - handle of the edge
%      X,Y      - new position of the edge
%      R        - radius of nodes
%
%   See also GRAPHEDIT

%   Author(s): P. Sucha
%   Copyright (c) 2004 CTU FEE
%   $Revision: 238 $  $Date: 2005-09-20 19:57:42 +0200 (út, 20 IX 2005) $

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


%Constans of edge
k=0.25*r;   %arrow size
lw=1;       %LineWidth

%Reduce size of edge 0-O
dx=x(2)-x(1);   dy=y(2)-y(1);   l=norm([dx dy]);
dx=dx/l;    dy=dy/l;
x(1)=x(1)+dx*(r);    y(1)=y(1)+dy*(r);
x(2)=x(2)-dx*(r);    y(2)=y(2)-dy*(r);

set(handle,'XData',x);	set(handle,'YData',y);
objectHandle=get(handle,'UserData');

%Repaint '->'
px=-dx*k+x(2);  py=-dy*k+y(2);
pxx=px-dy*k; pyy=py+dx*k;
set(objectHandle(1),'XData',[x(2) pxx]); set(objectHandle(1),'YData',[y(2) pyy]);

pxx=px+dy*k; pyy=py-dx*k;
set(objectHandle(2),'XData',[x(2) pxx]); set(objectHandle(2),'YData',[y(2) pyy]);

%Replace timing constaint
set(objectHandle(3),'Position',[x(1)+r*dx*0.75,y(1)+r*dy*1.05,0]);

return;

% end .. ge_move_edge
