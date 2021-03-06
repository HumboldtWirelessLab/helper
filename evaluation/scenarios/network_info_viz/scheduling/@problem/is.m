function bool = is(problem, var, value)
%IS  Check if problem is in quest type.
%
%    bool = IS(problem, var, value)
%      problem - object of PROBLEM.
%      var     - part of notation: alpha, betha, gamma, notation
%      value   - what is checket:
%           for alpha:    1, P, Q, R, O, F, J
%           for betha:    pmtn, rj, ...
%           for gamma:    Cmax, sumCj, sumwCj, Lmax, ...
%           for notation: SPNTL, CSCH, ...
%
%    See also: PROBLEM

%   Author(s): M. Kutil, P. Sucha
%   Copyright (c) 2004 CTU FEE
%   $Revision: 1717 $  $Date: 2007-09-19 15:39:01 +0200 (st, 19 IX 2007) $

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
 

if strcmpi(var,'alpha')
    bool = strcmpi(problem.machines_type,value(1));
    if(length(value) == 1 && (problem.machines_quantity==inf || problem.machines_quantity==1))
        return
    end
    machines_quantity = str2num(value(2:end));
    if(machines_quantity ~= problem.machines_quantity)
        bool = 0;
    end;
    return
elseif strcmpi(var,'betha')
    inputBetha = {};
    problemBetha = {};
    
    %analyse input betha parameters
    sep = strfind(value,',');         %',' is a separator
    sep = [0 sep (length(value)+1)];
    for(i=1:(length(sep)-1))
        inputBetha{i} = value((sep(i)+1):(sep(i+1)-1));
    end

    %analyse problem betha parameters
    %Extract Betha
    sep2 = strfind(problem.notation,'|');   %'|' is a separator
    betha = problem.notation((sep2(1)+1):(sep2(2)-1));
    sep = strfind(betha,',');               %',' is a separator
    sep = [0 sep (length(betha)+1)];
    for(i=1:(length(sep)-1))
        problemBetha{i} = betha((sep(i)+1):(sep(i+1)-1));
    end

    if(isempty(setxor(problemBetha,inputBetha)))
        bool = 1;
    else
        bool = 0;
    end
    
    return;
elseif strcmpi(var,'gamma')
    bool = strcmpi(problem.criterion,value);
    return 
elseif strcmpi(var,'notation')
    bool = strcmpi(problem.notation,value);
    return 
end
bool = 0;
return

%end .. @problem/is
