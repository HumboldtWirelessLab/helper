function plot(T, varargin)
%PLOT graphic display of task
%
%Synopsis
% PLOT(T[,keyword1,value1[,keyword2,value2[...]]])
% PLOT(T[,CELL])
%
%Description
% Properties:
%  T:
%    - task
%  keyword:
%    - configuration parameters for plot style
%  value:
%    - configuration value
%  CELL:
%    - cell array of configuration parameters and values
%
% Available keywords:
%  color:
%    - color of task
%  movtop:
%    - vertical position of task (array if task is preempted)
%  texton:
%    - show text description above task (defaut value is true)
%  textin:
%    - show name of task inside the task (defaut value is false)
%  textins:
%    - structure with textin param detail. (see a. taskset/plot)
%  asap:
%    - show ASAP and ALAP borders (defaut value is false)
%  period:
%    - draw period mark
%  timeOfs:
%    - time offset. Used by periodic tasks.
%
% See also TASK/GET_SCHT.

%   Author(s):  M. Kutil, Michal Sojka
%   Copyright (c) 2004 CTU FEE
%   $Revision: 1762 $  $Date: 2007-09-20 15:06:13 +0200 (čt, 20 IX 2007) $

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
if ni == 1 && iscell(varargin{1})
    varargin = varargin{1};
    ni = length(varargin);
elseif mod(ni,2) == 1
    error('Invalid count of input parameters.');
end

% default values
movtop = 0;
texton = 1;
textin = 0;
asapdraw = 0;
period_draw = 1;
color = get_graphic_param(T,'color');
if ~iscolor(color)
    color='g';
end
time_ofs = 0;
textins.fontsize = 12;
textins.textmovetop = 0;

i=1;
while i <= ni,
    switch lower(varargin{i})
        case 'color'
            color=varargin{i+1};
        case 'movtop'
            movtop=varargin{i+1};
        case 'texton'
            texton=varargin{i+1};
        case 'textin'
            textin=varargin{i+1};
        case 'asap'
            asapdraw=varargin{i+1};
        case 'timeofs'
            time_ofs=varargin{i+1};
        case 'period'
            period_draw=varargin{i+1};
        case 'textins'
            if (isstruct(varargin{i+1}))
                textins=varargin{i+1};
            end

        otherwise
            error(['Unknown parameter: ',varargin{i}]);
    end
    i=i+2;
end

start = T.ReleaseTime;
if (size(T.schStart,2))
    % Is schedule  - draw with schedule
    % Select propper part of schedule (for periodic tasks)

    %movtop full fill
    movtopfull(1:size(T.schStart,2))=movtop(1);
    movtopfull(1:size(movtop,2)) = movtop;
    movtop = movtopfull;
    
    act_sch = find(T.schStart >= time_ofs);
    start = T.schStart(act_sch);
    len = T.schLength(act_sch);
    cas_add = max(start+len);
    for i=1:size(start,2)
        handle = fill([start(i) start(i)+len(i) start(i)+len(i) start(i)], ...
            [movtop(i) movtop(i) movtop(i)+0.75 movtop(i)+0.75],color);
    end
else
    % Draw without schedule
    % with ASAP

    %movtop one
    movtop=movtop(1);
    
    if (asapdraw) & ~isempty(T.ASAP)
        handle = fill(time_ofs + ...
            [T.ASAP T.ASAP+T.ProcTime T.ASAP+T.ProcTime T.ASAP], ...
            [movtop(1) movtop(1) movtop(1)+0.75 movtop(1)+0.75], ...
            color);
        cas_add = T.ASAP+T.ProcTime;
    else
        % without ASAP
        handle = fill(time_ofs + ...
            [T.ReleaseTime T.ReleaseTime+T.ProcTime T.ReleaseTime+T.ProcTime T.ReleaseTime], ...
            [movtop(1) movtop(1) movtop(1)+0.75 movtop(1)+0.75], ...
            color);
        cas_add = T.ReleaseTime+T.ProcTime;
    end
end
holding = ishold;
hold on;

handle=plot(time_ofs + [T.ReleaseTime T.ReleaseTime],[movtop(1) movtop(1)+0.9],'k^-'); % release date
try
    set(handle,'MarkerFaceColor',color);
catch
    disp('a');
end
handle=plot(time_ofs + [T.Deadline T.Deadline],[movtop(end) movtop(end)+0.9],'kv-'); % deadline
set(handle,'MarkerFaceColor',color);
plot(time_ofs + [T.DueDate T.DueDate],[movtop(end) movtop(end)+0.9],'k-'); % duedate
if period_draw && ~isempty(T.schPeriod)
    plot(time_ofs + [T.schPeriod T.schPeriod],[movtop(1) movtop(1)+1.1],'r-'); % period
end

% range of axis x
casy=[T.ReleaseTime T.DueDate T.Deadline];
minx = min(casy(find(casy~=inf))); %min without inf
casy=[cas_add T.DueDate T.Deadline];
maxx = max(casy(find(casy~=inf))); %max without inf
for imovtop=1:length(movtop)
    plot(time_ofs + [minx maxx],[movtop(imovtop) movtop(imovtop)],'k-'); % axis
end

% Write text
reducename = schfeval('private/tex2mtex',T.Name);
if (texton)
    hand_text = text((minx+0.2),movtop(1)+1.3,reducename);
    set(hand_text,'FontWeight','bold');
    if (T.Weight ~= 1)
        text((minx+0.2),movtop(1)+1.2, ['Weight:  ' int2str(T.Weight)]);
    end
    if (length(T.Processor) ~= 0)
        text((minx+0.2),movtop(1)+1.1,['Processor: ' int2str(T.Processor)]);
    end
end
if (textin)
    hand_text = text((T.ReleaseTime*0+0.2+start(1)),movtop(1)+0.15+textins.textmovetop,reducename);
    set(hand_text,'FontWeight','normal');
    set(hand_text,'FontSize',textins.fontsize);
end
if (asapdraw)
    if ~isempty(T.ASAP)
        plot(time_ofs + [T.ASAP T.ASAP],[movtop(1) movtop(1)+0.9],'k--'); % asap
    end
    if ~isempty(T.ALAP)
        plot(time_ofs + [T.ALAP T.ALAP],[movtop(end) movtop(end)+0.9],'k--'); % alap
    end
end

% set axis
axis auto;
ax = axis;
axis([ax(1)-1 ax(2)+1 ax(3) ax(4)+0.5]);

if ( ~holding)
    hold off;
end

% switch off y-axes
set (get(handle,'Parent'),'YTickMode','manual');
set (get(handle,'Parent'),'YTick',[]);

% label
xlabel('t');
%end .. @task/plot
