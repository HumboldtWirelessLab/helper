function graphout = loadobj(graphin)
% LOADOBJ for graph class

%   Author(s): M. Kutil, V. Navratil
%   Copyright (c) 2004 CTU FEE
%   $Revision: 686 $  $Date: 2007-03-05 00:10:16 +0100 (po, 05 III 2007) $

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


if isa(graphin, 'graph')
    graphout = graphin;
else %graphin is old version
    num = length(graphin);
    graphout = cell(1,num);
    for i = 1:num
        graphtorepair = graphin(i);
        switch graphtorepair.version
            case 0.01
                graphtorepair.DataTypes = struct('edges',{[]},'nodes',{[]});
                graphtorepair.Color = [];
                graphtorepair.GridFreq = [];
            otherwise
                error('Wrong version');
        end
        graphtorepair.version = 0.02;
        schedobj_back = graphtorepair.schedobj;
        graphtorepair = rmfield(graphtorepair, 'schedobj'); 
        parent = schedobj;
        graphtorepair = class(graphtorepair, 'graph', parent);
        graphtorepair.schedobj = schedobj_back;
        graphout{i} = graphtorepair;
    end
    if num == 1
        graphout = graphout{1};
    end
end

%end .. @graph/loadobj
