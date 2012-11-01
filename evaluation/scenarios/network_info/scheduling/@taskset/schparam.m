function param=schparam(T,varargin)
%SCHPARAM returns parameters about schedule inside the set of tasks
%
%Synopsis
%  param = schparam(T[, keyword])
%
%Description
% Properties:
%  T:
%    - set of tasks
%  keyword:
%    - schedule properties
%  param:
%    - output value
%
% Keywords:
%  Cmax:
%    - Makespan
%  sumCj:
%    - Sum of completion times
%  sumwCj:
%    - Weighted sum of completion times
%  lmax:
%    - maximum lateness
%  period:
%    - Period
%  time:
%    - Solving time
%  memory:
%    - Memory alocation
%  iterations:
%    - Number of iterations
%
% If keyword isn't defined, then struct with all properties is returned.
%
% See also TASKSET/ADD_SCHEDULE.

%   Author(s):  M. Kutil, P.Sucha
%   Copyright (c) 2004 CTU FEE
%   $Revision: 1851 $  $Date: 2007-09-27 06:36:22 +0200 (čt, 27 IX 2007) $

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

if nargin==1
    param.cmax = schparam(T,'cmax');
    param.sumcj = schparam(T,'sumcj');
    param.sumwcj = schparam(T,'sumwcj');    
    param.sumuj = schparam(T,'sumuj');    
    param.lmax = schparam(T,'lmax');    
    param.time = schparam(T,'time');
    param.iterations = schparam(T,'iterations');
    param.memory = schparam(T,'memory');
    param.period = schparam(T,'period');	
else
    param = varargin{1};
    switch lower(param)
        case 'cmax'
            cmax=0;
            for i= 1: size(T)
                t = T.tasks{i};
                [start, length, proc]=get_scht(t);
                if cmax < max((start+length))
                    cmax = max((start+length));
                end
            end
            param = cmax;
        case 'sumcj'
            sumcj=0;
            for i= 1: size(T)
                t = T.tasks{i};
                [start, length, proc]=get_scht(t);
                sumcj=sumcj+max(start+length);
            end
            param = sumcj;
        case 'sumwcj'
            sumwcj=0;
            for i= 1: size(T)
                t = T.tasks{i};
                [start, length, proc]=get_scht(t);
                sumwcj=sumwcj+t.weight(1).*max(start+length);
            end
            param = sumwcj;         
        case 'sumuj'
            sumuj=0;
            for i= 1: size(T)
                t = T.tasks{i};
                [start, length, proc]=get_scht(t);
                if(max(start+length) > t.DueDate)
                    sumuj=sumuj+1;
                end
            end
            param = sumuj;
        case 'lmax'
            lmax=-inf;
            for i= 1: size(T)
                t = T.tasks{i};
                [start, length, proc]=get_scht(t);
                Lj = max(start+length) - t.DueDate;
                lmax = max(lmax,Lj);
            end
            param = lmax;
        case 'time'
            param = T.schedule.time;
        case 'iterations'
            param = T.schedule.iterations;
        case 'memory'
			param = T.schedule.memory;
		case 'period'
			period=[];
			period_num = [];
			for i= 1: size(T)
				t = T.tasks(i);
				[start, length, proc, task_period]=get_scht(t{1});
				period = [period task_period];
				if isempty(period_num) 
					period_num = task_period;
				elseif period_num ~= task_period
					period_num = NaN;
				end
			end
			if isnan(period_num)
				param = period;
			else
				param = period_num;
			end
		otherwise
			error('Nonexisting param');
    end
end
%end .. @taskset/schparam
