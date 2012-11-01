% HORN_DEMO Demo application of the scheduling with '1|pmtn,rj|Lmax' notation
%
%    See also HORN

%   Author(s): M. Kutil
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
disp('Demo of scheduling algorithm for problem ''1|pmtn,rj|Lmax''.');
disp('------------------------------------------------------');

%define scheduling problem
p=problem('1|pmtn,rj|Lmax');

%create set of tasks
T = randtaskset(6, [1 10], [0 15], inf, [25 35]);

disp(' ');
disp('An instance of the scheduling problem:');
get(T)


clf;
subplot(2,1,1);
title('Input set of tasks');
plot(T,'proc',0);

subplot(2,1,2);
title('Schedule obtained by Horn''s algorithm');
TS = horn(T,p);
plot(TS);

%end of file
