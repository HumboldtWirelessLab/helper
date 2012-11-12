%ILINPROG_DEMO Demonstrates the universal Integer Linear Programming
%    interface ILINPROG on a simple example.
%
%    See also ILINPROG

%   Author(s): P. Sucha
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
disp('Integer linear programming demo.');
disp('------------------------------------------------------');
disp(' ');

disp('An example of integer linear programming problem:');
disp(' ');
disp('max 10*x1 + 6*x2 + 4*x3');
disp(' ');
disp('Subject to:');
disp('       x1 +   x2 +   x3 <= 100');
disp('    10*x1 + 4*x2 + 5*x3 <= 600');
disp('     2*x1 + 2*x2 + 6*x3 <= 300');
disp('where:');
disp('     x1>=0, x2>=0, x3>=0');
disp('     x1,x2,x3 are integer variables');
disp(' ');

c=[10,6,4]';                %objective function
A=[1,1,1;...
   10,4,5;...
   2,2,6];                  %matrix representing linear constraints
b=[100,600,300]';           %right sides for the inequality constraints
ctype=['L','L','L']';       %sense of the inequalities
lb=[0,0,0]';                %lower bounds of variables
ub=[inf inf inf]';          %upper bounds of variables
vartype=['I','I','I']';     %types of variables

schoptions=schoptionsset('ilpSolver','glpk','solverVerbosity',0);   %ILP solver options (use default values)

disp('The solution is:');
[xmin,fmin,status,extra] = ilinprog(schoptions,-1,c,A,b,ctype,lb,ub,vartype)

% end .. ILINPROG_DEMO
