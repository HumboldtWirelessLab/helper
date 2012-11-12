% BRATLEY_DEMO Demo application of the scheduling with '1|rj,~dj|Cmax' notation
%
%   see also BRATLEY

%   Author(s): R. Capek
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

clc;
disp('Demo of scheduling algorithm for problem ''1|rj,~dj|Cmax''.');
disp('----------------------------------------------------------------');


%define the problem
prob=problem('1|rj,~dj|Cmax');

%set some tasks
T=taskset([2 1 2 2]);
T.Deadline=([7 5 6 4]);
T.ReleaseTime=([4 1 1 0]);
%T = randtaskset(6, [1 5], [0 15], [10 30]);

% Add colour for each task in taskset
T = colour(T);

disp(' ');
disp('An instance of the scheduling problem:');
get(T)

%plot unscheduled
subplot(2,1,1);
plot(T);
title('Tasks to be scheduled.')

%call solving algorithm
result=bratley(T,prob);

%if exist solution
if ~isempty(result)
    subplot(2,1,2);
    plot(result);
    title('Schedule obtained by Bratley''s algorithm.');
end

%end of file
