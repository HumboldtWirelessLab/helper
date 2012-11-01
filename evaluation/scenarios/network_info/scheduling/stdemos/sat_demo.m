% SAT_DEMO Demo application of the scheduling with 'P|prec|Cmax' notation
%  by SAT solver use.
%
%    See also SATSCH

%   Author(s): M. Kutil
%   Copyright (c) 2005 CTU FEE
%   $Revision: 1518 $  $Date: 2007-09-14 14:06:48 +0200 (pá, 14 IX 2007) $

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
disp(' SAT scheduler demo ');
disp(' ----------------------');

%create set of tasks
t1=task('task1',5,1,22);
t2=task('task2',3,5,38);
t3=task('task3',6,1,22);
t4=task('task4',4,3,27);
t5=task('task5',1,5,30);
t6=task('task6',7,5,21);
t7=task('task7',9,6,32);
t8=task('task8',6,8,30);
t9=task('task9',2,1,45);
t10=task('task10',6,2,40);
t11=task('task11',10,15,30);
T=taskset([t1 t2 t3 t4 t5 t6 t7 t8 t9 t10]);

disp(' ');
disp('An instance of the scheduling problem:');
get(T)


%define the problem
p=problem('P|prec|Cmax');
subplot(2,1,1)
plot(T);
title('Scheduling problem');

TS = satsch(T,p,2);
subplot(2,1,2)
plot(TS);
title('Solved schedule')

%end of file
