function display(prob)
%DISPLAY   Display Problem
%
% Syntax
%    DISPLAY(prob)

%   Author(s):  M. Kutil
%   Copyright (c) 2004 CTU FEE
%   $Revision: 371 $  $Date: 2006-03-20 11:01:11 +0100 (po, 20 III 2006) $

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
 

if (prob.machines_quantity == inf) | ((prob.machines_quantity == 1) & (prob.machines_type == '1'))
    quatity = '';
else
    quatity = int2str(prob.machines_quantity);
end
alphatext = [prob.machines_type quatity];

betha=fieldnames(prob.betha);
bethatext = '';
conjunction ='';
for i = 1 : length(betha);
    if getfield(prob.betha,betha{i})>0 | (strcmp(betha{i},'pj') & getfield(prob.betha,betha{i})>=0)
        if strcmp(betha{i},'intree')
            betha{i} = 'in-tree';
        elseif strcmp(betha{i},'pj')
            betha{i} = ['pj=' num2str(getfield(prob.betha,betha{i}))];
        end
        bethatext=strcat(bethatext,conjunction,betha{i});
        conjunction = ', ';
    end
end

gammatext = prob.criterion;

if isempty(alphatext) & isempty(bethatext) & isempty(gammatext) & ~isempty(prob.notation)
    disp(prob.notation);
else
    disp([prob.machines_type quatity '|' bethatext '|' prob.criterion]);
end

%end .. @problem/display
