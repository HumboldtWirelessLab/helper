function [x,y]=bezier(x0,y0,x1,y1,x2,y2,x3,y3,varargin)
%BEZIER computes points on Bezier curve
%
%Synopsis
%  [x,y] = BEZIER(x0,y0,x1,y1,x2,y2,x3,y3[,reduction])
%
%Description
% A cubic Bezier curve is defined by four points. Two are endpoints.
% (x0,y0) is the origin endpoint. (x3,y3) is the destination endpoint.
% The points (x1,y1) and (x2,y2) are control points.
%
% Function remove points in which vectors given by adjacent points inclined
% angel with tangent smaller than input value 'reduction'. 
% Default value is 0.005.
%
% See also TASKSET/PLOT. 

% http://www.moshplant.com/direct-or/bezier/

%   Author(s):  M. Kutil
%   Copyright (c) 2004 CTU FEE
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

cx = 3 * (x1 - x0);
bx = 3 * (x2 - x1) - cx;
ax = x3 - x0 - cx - bx;

cy = 3 * (y1 - y0);
by = 3 * (y2 - y1) - cy;
ay = y3 - y0 - cy - by;

t=0:0.005:1;
x = ax*t.^3 + bx*t.^2 + cx*t + x0;
y = ay*t.^3 + by*t.^2 + cy*t + y0;

% redundant points removing
if (nargin > 8) && isnumeric(varargin{1})
    tangent = varargin{1};
else
    tangent = 0.005;
end

k = ones(1,length(x));
for i=2:length(x)-1
    if (x(i)-x(i-1)) ~= 0
        k1 = (y(i)-y(i-1))/(x(i)-x(i-1));
    else
        k1 = inf;
    end

    if (x(i+1) - x(i)) ~= 0
        k2 = (y(i+1)-y(i))/(x(i+1) - x(i));
    else
        k2 = inf;
    end
    k(i) = tan(atan(k1)-atan(k2));
end
different = abs(k)>=tangent;
different(1) = 1;
different(end) = 1;
different = find(different);
x = x(different);
y = y(different);
