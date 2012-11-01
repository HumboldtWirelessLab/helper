function ptask = ptask(varargin)
%PTASK  Creation of object ptask.
%
%  Creation:
%    ptask = PTASK([Name,]ProcTime,Period[,ReleaseTime[,Deadline[,Duedate[,Weight[,Processor]]]]])
%    periodic task with parameters:
%      name   - name of task (must by char!)
%      p      - proces time
%      period - period of the task
%      r      - release date
%      dl     - deadline
%      dd     - duedate
%      w      - weight
%      machine - dedicate machine
%    The output task is a PTASK object.  
%
%  See also SN.

%   Author(s): M. Kutil, Michal Sojka
%   Copyright (c) 2004 CTU FEE
%   $Revision: 81 $  $Date: 2004-11-15 12:37:02 +0100 (po, 15 XI 2004) $

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
 


next = 1;
if (nargin >= next) & isa(varargin{next},'char'),
    name = varargin{next};
    varargin = {varargin{next+1:end}};
    if nargin < 3
        error('Not enaugh parameters');
    end
else
    name='';
    if nargin < 2
        error('Not enaugh parameters');
    end
end

parent = task(name, varargin{[1,3:end]});

ptask = struct(...
        'parent',       'task',...
        'Period',       varargin{2},...
        'version',      0);


ptask = class(ptask, 'ptask', parent); 
