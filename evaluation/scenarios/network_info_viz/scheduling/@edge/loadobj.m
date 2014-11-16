function edgeout = loadobj(edgein)
% LOADOBJ for edge class

%   Author(s): M. Kutil
%   Copyright (c) 2004 CTU FEE
%   $Revision: 827 $  $Date: 2007-03-26 11:51:18 +0200 (po, 26 III 2007) $

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

if isa(edgein, 'edge')
    edgeout = edgein;
else %edgein is old version
    num = length(edgein);
%    edgeout = cell(1,num);
    for i = 1:num
        edgetorepair = edgein(i);
        switch edgetorepair.version
            case 0.01
                edgetorepair.Color = [];           
                edgetorepair.Position = [];
                edgetorepair.LineStyle = [];
                edgetorepair.LineWidth = [];
                edgetorepair.Arrow = [];
                edgetorepair.TextParam = [];
                edgetorepair.Undirected = 0;
    		otherwise
                error('Wrong version');
        end
        edgetorepair.version = 0.02;
        schedobj_back = edgetorepair.schedobj;
        edgetorepair = rmfield(edgetorepair, 'schedobj'); 
        parent = schedobj;
        edgetorepair = class(edgetorepair, 'edge', parent);
        edgetorepair.schedobj = schedobj_back;
        edgeout(i) = edgetorepair;
    end
    if num == 1
        edgeout = edgeout(1);
    end
end

%end .. @edge/loadobj
