%IQUADPROG_DEMO Demonstrates the universal Integer Quadratic Programming
%    interface IQUADPROG on a simple example.
%
%    See also IQUADPROG, ILINPROG

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
disp('Integer quadratic programming demo.');
disp('------------------------------------------------------');
disp(' ');

disp('An example of integer quadratic programming problem:');
disp(' ');
disp('min - x1 - 2*x2 - 3*x3 - x4');
disp('    + 0.5 ( 33*x1*x1 + 22*x2*x2 + 11*x3*x3 - 12*x1*x2 - 23*x2*x3)');
disp(' ');
disp('Subject to:');
disp('    - x1 +   x2 + x3  + 10*x4  <= 20');
disp('      x1 - 3*x2 + x3           <= 30');
disp('             x2      - 3.5*x4   =  0');
disp('where:');
disp('     0<=x1<=1, 0<=x1<=1, 0<=x1<=1, 0<=x1<=1');
disp('     x4 is a binary variable');
disp(' ');


H= [33  -6     0    0;...
    -6  22    -11.5 0;...
    0   -11.5  11   0;...
    0   0      0    0];                 %quadratic objective function
c=[-1 -2 -3 -1]';                       %linear objective function
A=[-1 1 1 10;...
    1 -3 1 0;...
    0 1 0 -3.5];                        %matrix representing linear constraints
b=[20 30 0]';                           %right sides for the inequality constraints
ctype=['L','L','E']';                   %sense of the inequalities
lb=[0; 0; 0; 0];                        % lower bound on variables
ub=[1; 1; 1; 1];                        % upper bound on variables
vartype=['C' 'C' 'C' 'B']';             % variable type

schoptions=schoptionsset('miqpSolver','miqp','solverVerbosity',0);   %ILP solver options (use default values)

disp('The solution is:');
[xmin,fmin,status,extra] = iquadprog(schoptions,1,H,c,A,b,ctype,lb,ub,vartype)


% end .. IQUADPROG_DEMO
