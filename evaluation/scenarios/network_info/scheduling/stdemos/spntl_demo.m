%SPNTL_DEMO Demo application of the scheduling with Positive
%    and Negative Time-Lags algorithm
%
% Description
%    This demo shows an example of SPNTL scheduling algortihm
%    presented in P. Sucha and Z. Hanzalek, "Scheduling with Start
%    Time Related Deadlines", CCA/ISIC/CACSD'04 IEEE Computer Aided
%    Control Systems Design, 2004.
%
%    See also SPNTL

%   Author(s): P. Sucha
%   Copyright (c) 2005 CTU FEE
%   $Revision: 1545 $  $Date: 2007-09-18 10:41:22 +0200 (út, 18 IX 2007) $

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
disp('Demo of scheduling algorithm for problem with');
disp(' positive and negative time lags.');
disp('--------------------------------------------------');

schDemoRoot = fileparts(mfilename('fullpath'));
benchmarkDir=[schDemoRoot filesep 'benchmarks' filesep 'spntl'];
load([benchmarkDir filesep 'spntl_graph.mat']);

g.Name = 'positive and negative time lags';
graphedit(g);

%Conversion graph -> taskset
T=taskset(g,'n2t',@node2task,'ProcTime','Processor','e2p',@edges2param);
%T=taskset(g);   

disp(' ');
disp('An instance of the scheduling problem:');
get(T)

prob=problem('SPNTL');

disp(' ');
disp('Scheduling:');
schoptions=schoptionsset('spntlMethod','BaB','verbose',2);
TS = spntl(T, prob, schoptions);
plot(TS);

% end .. SPNTL_DEMO
