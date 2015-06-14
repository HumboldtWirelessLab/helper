function [TS] = alg1rjcmax(T, prob)
%ALG1RJCMAX computes schedule with Earliest Release Date First algorithm 
%
% Synopsis
%   TS = alg1rjcmax(T, problem)
%
% Description
%	TS = alg1rjcmax(T, problem) finds schedule of the scheduling problem 1|rj|Cmax.
%   Parameters:
%    T:
%      - input set of tasks
%    TS:
%      - set of tasks with a schedule
%    PROBLEM:
%      - description of scheduling problem (object PROBLEM) - '1|rj|Cmax'
%
% See also PROBLEM/PROBLEM, TASKSET/TASKSET, ALG1SUMUJ, BRATLEY, CYCSCH.

%   Author(s): O. Nyvlt, R.Capek, P. Sucha
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


if is(prob,'alpha','1') && is(prob,'betha','rj') && is(prob,'gamma','Cmax')

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 n = length(T.Name);           %number of tasks
 s = inf*ones(1,n);            %start dates of tasks
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Algorithm start 
 % SEE Blazewicz - Scheduling Computer and Manufacturing Processes
 %  2. edition, page 32
 
 %%%%%%% Sort tasks in non-decreasing release dates 
 [T1, order] = sort(T,'ReleaseTime');
 
 %%%%%%% Computing of Start dates of scheduled Tasks
 time = 0;
 for i = 1:n
   s(order(i)) = max(time,T1.ReleaseTime(i));
   time = s(order(i)) + T1.proctime(i);   
 end   

 %%%%%%%%% Algorithm finishing
 description = 'ALG1RJCMAX for 1|rj|Cmax';
 add_schedule(T,description,s,T.ProcTime);      %Add schedule into taskset
 TS = T;
else
    error('This problem can''t be solved by ALG1RJCMAX algorithm.');
end
