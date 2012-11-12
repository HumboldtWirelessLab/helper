function task = task(varargin)
%TASK creates object task.
%
%Synopsis
% task = TASK([Name,]ProcTime[,ReleaseTime[,Deadline[,DueDate[,Weight[,Processor]]]]])
%
%Description
% Creates a task with parameters:
%  Name:
%    - name of the task (must by char!)
%  ProcTime:
%    - processing time (execution time)
%  ReleaseTime:
%    - release date (arrival time)
%  Deadline:
%    - deadline
%  DueDate:
%    - due date
%  Weight:
%    - weight (priotiry)
%  Processor:
%    - dedicated processor
%
% The output task is a TASK object.
%
% See also TASKSET/TASKSET.

%   Author(s): M. Kutil, Michal Sojka
%   Copyright (c) 2004 CTU FEE
%   $Revision: 1750 $  $Date: 2007-09-20 11:07:47 +0200 (Ät, 20 IX 2007) $

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
 

na = nargin;
if na>=1 & isa(varargin{1},'task'),
   % Quick exit for TASK(T) with T of class TASK
   task = varargin{1};
   if na > 1,
%  modify for more parameters.
   end;
   return;
end;    

next = 1;
if (na >= next) & isa(varargin{next},'char'),
    name = varargin{next};
    next = next + 1;
else
    name='';
end

[p,next]=set_parameter(varargin,next,-inf);
[r,next]=set_parameter(varargin,next,0);
[dl,next]=set_parameter(varargin,next,inf);
[dd,next]=set_parameter(varargin,next,inf);
[w,next]=set_parameter(varargin,next,1);
[machine,next]=set_parameter(varargin,next,[]);

% Create the structure
task = struct(...
        'parent', 'schedobj',...
        'Name',name,...
        'ProcTime',p,...
        'ReleaseTime',r,...
        'Deadline',dl,...
        'DueDate',dd,...   
        'Weight',w,...
        'Processor',machine,...  
        'schStart',[],...
        'schLength',[],...
        'schProcessor',[],...
        'version',0.04,...
        'UserParam',[],...
        'ALAP',[],...
        'ASAP',[],...
		'schPeriod',[]);
	
% UserParam is user paramters vector
% GrParam is struct for graphics interpretaion
% sch... are parameters of schedul
% ALAP ASAP - parameters inspired from [NR00, MF02, CGK]
    
% Create a parent object
parent = schedobj;
    
% Label task as an object of class TASK
task = class(task,'task', parent); 

% function set_param
function [par, next] = set_parameter(var, next, defvalue)
if size(var,2)>=next & (isa(var{next},'double'))
    par = var{next};
    next = next + 1;
else par = defvalue; end

%end .. @task/task

% Literature
%[NR00]
%  M. Narasimhan and J. Ramanujam. On lower bounds for scheduling problems in high-level synthesis. In DAC '00: Proceedings of the 37th conference on Design automation, pages 546–551, New York, NY, USA, 2000. ACM Press. (doi:10.1145/337292.337573)
%[MF02]
%  Seda Ogrenci Memik and Farzan Fallah. Accelerated sat-based scheduling of control/data flow graphs. In IEEE International Conference on Computer Design (ICCD), Germany, September 2002. Freiburg.
%[CGK]
%  Thomas Christensen, Morten Gade, and Rasmus Aslak Kj?r. Optimal Scheduling using SAT-solving and Bounded Model Checking. Avaible at http://www.cs.aau.dk/~mg/Dat4.ps.
