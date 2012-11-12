%HU_DEMO Demo application of scheduling with 'P|in-tree,pj=1|Cmax'
% notation
%
%Synopsis
%       HU_DEMO
%
% See also HU.

%   Author(s): J. Martinsky
%   Copyright (c) 2007 CTU FEE

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

clc;
disp('Demo of scheduling algorithm for problem ''P|in-tree,pj=1|Cmax''.');
disp('--------------------------------------------------------------');

%define scheduling problem
p = problem('P|in-tree,pj=1|Cmax');

%create set of tasks
prec = [
    0 0 0 0 0 0 1 0 0 0 0 0
    0 0 0 0 0 0 1 0 0 0 0 0
    0 0 0 0 0 0 0 1 0 0 0 0
    0 0 0 0 0 0 0 0 1 0 0 0
    0 0 0 0 0 0 0 0 1 0 0 0
    0 0 0 0 0 0 0 0 0 1 0 0
    0 0 0 0 0 0 0 0 0 1 0 0
    0 0 0 0 0 0 0 0 0 0 1 0
    0 0 0 0 0 0 0 0 0 0 1 0
    0 0 0 0 0 0 0 0 0 0 0 1
    0 0 0 0 0 0 0 0 0 0 0 1
    0 0 0 0 0 0 0 0 0 0 0 0
    ];
T = taskset([1 1 1 1 1 1 1 1 1 1 1 1],prec);
processors = 3;

disp(' ');
disp('An instance of the scheduling problem:');
get(T)


TS = hu(T,p,processors);

%display taskset
plot(TS);
title('Scheduled obtained by Hu`s algorithm');

%end of file
