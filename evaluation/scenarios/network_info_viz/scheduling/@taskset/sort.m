function [TS, varargout] = sort(TS,varargin)
%SORT  return sorted set of tasks over selected parameter.
%
% Synopsis
%    TS = SORT(TS,parameter[,tendency])
%    [TS,order] = SORT(TS,parameter[,tendency])
%
% Description
%    The function sorts tasks inside taskset. Input parameters are:
%      TS:
%                - Set of tasks
%      parameter:
%                - the propety for sorting ('ProcTime','ReleaseTime',
%                  'Deadline','DueDate','Weight','Processor' or
%                  any vector with the same length as taskset)
%      tendency:
%                - 'inc' as increasing (default), 'dec' as decreasing
%      order:
%                - list with re-arranged order
%
%    note: 'inc' tendenci is exactly nondecreasing, and 'dec' is exactly
%          calcuated as nonincreasing
%
%    See also TASKSET/TASKSET

%   Author(s):  M. Kutil, M. Stibor
%   Copyright (c) 2005 CTU FEE
%   $Revision: 1764 $  $Date: 2007-09-20 15:07:57 +0200 (čt, 20 IX 2007) $

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

ni = length(varargin);
if ni >= 1
    if sum(strcmpi(varargin{1},{'ProcTime','ReleaseTime','Deadline','DueDate','Weight','Processor'})) | length(varargin{1})==size(TS);
        
        if sum(strcmpi(varargin{1},{'ProcTime','ReleaseTime','Deadline','DueDate','Weight','Processor'}));
            sortval = get(TS,varargin{1});    
        elseif length(varargin{1})==size(TS)
            sortval = varargin{1};
        end
    
        if ni == 2 & strcmpi(varargin{2},'dec')
            ordering = -1;
        else
            ordering = 1;
        end    
        [varnull,ordertasks]=sort(sortval.*ordering);

        TS.tasks = TS.tasks(ordertasks);
        
        % new prec matrix
        [fromtask,totask,numberofedge]=find(TS.Prec);
        TS.Prec = zeros(length(ordertasks));
        for i = 1:length(fromtask)
            TS.Prec(find(ordertasks==fromtask(i)),find(ordertasks==totask(i))) = numberofedge(i);
        end
    else
        error('Unknown parameter!?');
    end
else
    error('Parameter isn''t specified');
end

if nargout==2
    varargout{1} = ordertasks;
end
%end .. @taskset/sort
