function edge_h=ge_edge(x,y,r,color,e)
%GE_EDGE places edge between two nodes to current figure
%    EDGE_H = GE_EDGE(X,Y,R,COLOR,E) creates an edge 
%      EDGE_H   - handle of created edge
%      X,Y      - vector of the edge position
%      R        - radius of nodes
%      COLOR    - color of the edge
%      E        - text label of the edge
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
k=0.25*r;    %arrow size
lw=1;       %LineWidth

%Reduce size of edge 0-O
dx=x(2)-x(1);   dy=y(2)-y(1);   l=norm([dx dy]);
dx=dx/l;    dy=dy/l;
x(1)=x(1)+dx*(r);    y(1)=y(1)+dy*(r);
x(2)=x(2)-dx*(r);    y(2)=y(2)-dy*(r);

edge=sprintf('%s:',color);  %For forward edge
    
h=plot(x,y,edge);    
set(h,'LineWidth',lw)
edge_h=h;

%Paint '->'
px=-dx*k+x(2);  py=-dy*k+y(2);
pxx=px-dy*k; pyy=py+dx*k;
h1=plot([x(2) pxx],[y(2) pyy],color);
set(h1,'LineWidth',lw)
pxx=px+dy*k; pyy=py-dx*k;
h2=plot([x(2) pxx],[y(2) pyy],color);
set(h2,'LineWidth',lw)

%Place timing constaint
edgeString=num2str(e);
edgeString = regexprep(edgeString,' +',' ');
edgeString=strrep(edgeString,'  ',' ');  %Remove doublespaces
h3=text(x(1)+r*dx*0.75,y(1)+r*dy*1.05,edgeString);
set(h3,'HorizontalAlignment','Center');
set(h3,'Color',color);

set(edge_h,'UserData',[h1 h2 h3]);

return;

% end .. ge_edge
