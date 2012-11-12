function color=colorfromcolormap(n)
%COLORFROMCOLORMAP   Compute n colors from color map
%
% Syntax
%    color=colorfromcolormap(n)
%       n     - number of colors
%       color - n x 3 matrix with colors from the colormap
%
% See also: colormap, colorcube

%   Author(s):  M. Kutil
%   Copyright (c) 2004 CTU FEE
%   $Revision: 831 $  $Date: 2007-03-26 22:37:58 +0200 (po, 26 III 2007) $

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

currentFigureHandler = get(0,'CurrentFigure');
mapColor = colormap;
if isempty(currentFigureHandler)
    close; %Close figure opened by colormap command
end

colorPointsLength = size(mapColor,1)/(n+1);
colorPoints = colorPointsLength:colorPointsLength:size(mapColor,1);
colorPoints = colorPoints(1:max(length(colorPoints)-1,1));

colorPre = mapColor(max(floor(colorPoints),1),:);
colorPost = mapColor(ceil(colorPoints),:);


color = mapColor(max(floor(colorPoints),1),:) + (colorPost-colorPre).*[(colorPoints-floor(colorPoints))' (colorPoints-floor(colorPoints))' (colorPoints-floor(colorPoints))'];