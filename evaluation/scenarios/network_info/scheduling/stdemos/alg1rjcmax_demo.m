% ALG1RJCMAX_DEMO Demo application of the scheduling problem '1|rj|Cmax'.
%
%    See also ALG1RJCMAX

%   Author(s): R.Capek, P. Sucha
%   Copyright (c) 2006 CTU FEE
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

clc;
disp('Demo of scheduling algorithm for problem ''1|rj|Cmax''.');
disp('------------------------------------------------------');


%define the problem
p = problem('1|rj|Cmax');

%create set of tasks
t1=task('t1', 2, 3);
t2=task('t2', 3, 0);
t3=task('t3', 1, 4);
t4=task('t4', 2, 1);
t5=task('t5', 4, 9);
T = taskset([t1 t2 t3 t4 t5]);

%display taskset
figure(1)
subplot(2,1,1)
plot(T);
title('Tasks to be scheduled.');

disp(' ');
disp('An instance of the scheduling problem:');
get(T)

%call a scheduling algorithm
TS = alg1rjcmax(T,p);

%display results
subplot(2,1,2)
plot(TS);
title('Schedule obtained by ''alg1rjcmax'' algorithm.');

%end of file
