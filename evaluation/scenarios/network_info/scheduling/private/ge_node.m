function node_h=ge_node(x,y,r,color,name,d)
%GE_NODE  places node to current figure
%    NODE_H=ge_node(X,Y,R,COLOR,NAME,D) creates an node 
%      NODE_H   - handle of created node
%      X,Y      - position of the node
%      R        - radius of nodes
%      COLOR    - color of the node
%      NAME     - text label of the node
%      D        - second text label of the node
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


%Compute circle
%node_h=rectangle('Curvature', [1 1],'Position', [x y r r]);
polX=0:36:360-36;
polX=polX*pi/180;
polY=r*sin(polX(:))+y;
polX=r*cos(polX(:))+x;

%Place name
h1=text(x,y,name);
set(h1,'HorizontalAlignment','Center');
set(h1,'FontWeight','Bold');
set(h1,'EraseMode','xor');

%Place execution time
nodeString=num2str(d);
nodeString = regexprep(nodeString,' +',' ');
%nodeString=strrep(nodeString,'  ',' ');  %Remove doublespaces
h2=text(x+r/2,y-r/2,nodeString);
set(h2,'HorizontalAlignment','Center');
set(h2,'FontAngle','Italic');
set(h2,'EraseMode','xor');

%Paint circle
node_h=fill(polX,polY,color);
set(node_h,'EraseMode','xor');

set(node_h,'UserData',[h1 h2]);

return;

% end .. ge_node
