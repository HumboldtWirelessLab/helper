function nodeout = loadobj(nodein)
% LOADOBJ for node class

%   Author(s): M. Kutil
%   Copyright (c) 2004 CTU FEE
%   $Revision: 793 $  $Date: 2007-03-19 13:13:57 +0100 (po, 19 III 2007) $

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

if isa(nodein, 'node')
    nodeout = nodein;
else %nodein is old version
    num = length(nodein);
%    nodeout = cell(1,num);
    for i = 1:num
        nodetorepair = nodein(i);
        switch nodetorepair.version
            case 0.01
                schedobjolddata = struct(nodein(i).schedobj);
                nodetorepair.GraphicParam{1}.x = schedobjolddata.GrParam.position(1);
                nodetorepair.GraphicParam{1}.y = schedobjolddata.GrParam.position(2);
                nodetorepair.GraphicParam{1}.width  = 30;
                nodetorepair.GraphicParam{1}.height = 30;
                nodetorepair.GraphicParam{1}.curvature = [1 1];
                nodetorepair.GraphicParam{1}.facecolor = schedobjolddata.GrParam.color;
                nodetorepair.GraphicParam{1}.linewidth = 1;
                nodetorepair.GraphicParam{1}.linestyle = '-';
                nodetorepair.GraphicParam{1}.edgecolor = [0 0 0];             
                nodetorepair.TextParam = [];
            otherwise
                error('Wrong version');
        end
        nodetorepair.version = 0.02;
        schedobj_back = nodetorepair.schedobj;
        nodetorepair = rmfield(nodetorepair, 'schedobj'); 
        parent = schedobj;
        nodetorepair = class(nodetorepair, 'node', parent);
        nodetorepair.schedobj = schedobj_back;
        nodeout(i) = nodetorepair;
    end
    if num == 1
        nodeout = nodeout(1);
    end
end

%end .. @node/loadobj
