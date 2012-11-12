function plot(T, varargin)
%PLOT   Graphics display of a periodic task
%
% Syntax
%    PLOT(T[,C1,V1,C2,V2...])
%      T        - task
%      Cx       - configuration parameters for plot style
%      Vx       - configuration value
%      
%     parameters:
%       color    - color of a task
%       movtop   - vertical position of a task
%       texton   - show text description above a task (defaut value is true)
%       maxTime - default 3 times task's period

%   Author(s):  M. Kutil, Michal Sojka
%   Copyright (c) 2004 CTU FEE
%   $Revision: 587 $  $Date: 2006-11-02 15:20:56 +0100 (čt, 02 XI 2006) $

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
if mod(ni,2) == 1
    error('Invalid count of input parameters.');
end 
i=1;
while i <= ni,
    switch lower(varargin{i})
        case 'color'
            colorInd=i+1;
        case 'movtop'
            movtopInd=i+1;
        case 'texton'
            textonInd=i+1;
        case 'maxtime'
            maxtime=varargin{i+1};
            varargin(i:i+1)=[];
            ni = ni - 2;
    end
    i=i+2;
end


if ~exist('movtopInd','var') 
    varargin = {varargin{:}, 'movtop', 0};
end
if ~exist('textonInd','var') 
    varargin = {varargin{:}, 'texton', 1};
end
if ~exist('maxtimeInd','var') 
    maxtime = 3*T.Period;
end

holding = ishold;
hold on;

time = 0;

while time <= maxtime
    args = {varargin{:} , 'timeofs' , time};
    plot(T.task, args);
    time = time + T.Period;
end

if ( ~holding) 
    hold off;
end

%end .. @ptask/plot
