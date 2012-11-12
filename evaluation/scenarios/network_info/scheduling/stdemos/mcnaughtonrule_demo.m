% MCNAUGHTON_DEMO Demo application of the scheduling with 'P|pmtn|Cmax' notation
%
%   This demo file shows how to solve a P|pmtn|Cmax problem using
%   McNaughton rule. The tasks in taskset T are assigned to 4 identical
%   processors in order minimizing Cmax. 
%
%   see also mcnaughtonrule

%   Author(s): M. Silar, P.Sucha
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
disp('Demo of Mc''Naughton''s algorithm for problem ''P|pmtn|Cmax''.');
disp('------------------------------------------------------');


%definition of taskset
T=taskset([11 23 9 4 9 33 12 22 25 20]);
T.Name={'t_1' 't_2' 't_3' 't_4' 't_5' 't_6' 't_7' 't_8' 't_9' 't_1_0' };

disp(' ');
disp('An instance of the scheduling problem:');
get(T)


%definition of problem to be solved 
p = problem('P|pmtn|Cmax');

%McNaughton algorithm
T = mcnaughtonrule(T,p,4);

%plot of the final schedule
plot(T,'proc',1); 

%end of file

