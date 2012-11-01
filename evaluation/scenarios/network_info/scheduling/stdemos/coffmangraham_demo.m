%COFFMANGRAHAM_DEMO Demo application of scheduling with 'P2|prec,pj=1|Cmax'
%notation
%
%Synopsis
%       COFFMANGRAHAM_DEMO
%
%See also COFFMANGRAHAM, HU.

%   Author(s): J. Martinsky, P. Sucha
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
disp('Demo of scheduling algorithm for problem ''P2|prec,pj=1|Cmax''.');
disp('-------------------------------------------------------------');

%define the problem
p=problem('P2|prec,pj=1|Cmax');

%create set of tasks
prec = [0 0 0 1 0 0 0 0 0 0 0 0 0
        0 0 0 1 1 0 0 0 0 0 0 0 0
        0 0 0 0 1 1 0 0 0 0 0 0 0
        0 0 0 0 0 0 1 1 0 0 0 0 0
        0 0 0 0 0 0 0 0 1 0 0 0 0
        0 0 0 0 0 0 0 0 1 1 0 0 0
        0 0 0 0 0 0 0 0 0 0 1 0 0
        0 0 0 0 0 0 0 0 0 0 1 1 0
        0 0 0 0 0 0 0 1 0 0 0 0 1
        0 0 0 0 0 0 0 0 0 0 0 0 1
        0 0 0 0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0 0 0 0
    ];
T=taskset([1 1 1 1 1 1 1 1 1 1 1 1 1],prec);

disp(' ');
disp('An instance of the scheduling problem:');
get(T)

%solve the problem
TS=coffmangraham(T,p);

title('Scheduled obtained by Hu`s algorithm');
plot(TS);

%end of file
