%CSSIM_DEMO Demo application of Cyclic Scheduling Simulator.
%
%    See also CSSIMIN, CSSIMOUT.

%   Author(s): P. Sucha
%   Copyright (c) 2005 CTU FEE
%   $Revision: 1519 $  $Date: 2007-09-14 14:58:11 +0200 (pá, 14 IX 2007) $

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
schDemoRoot = fileparts(mfilename('fullpath'));
benchmarkDir=[schDemoRoot filesep 'benchmarks' filesep 'cssim'];

disp('Demo application of Cyclic Scheduling Simulator');
disp('-----------------------------------------------');
disp('1: dsvf.m');
disp('2: psd.m');
disp('0: exit');
alg=input('Choice an algorithm:');

switch(alg)
    case 0
        return
    case 1
       dsvffile=[benchmarkDir filesep 'dsvf.m'];
    case 2
       dsvffile=[benchmarkDir filesep 'psd.m'];
    otherwise
       error('Incorrect choice.')
end

%

schoptions=schoptionsset('verbose',1,'cycSchMethod','integer','qmax',0);

%Parse input file
disp(' ');
disp(['Processing input file:' dsvffile]);
[T,m]=cssimin(dsvffile,schoptions);

%Schedule generated taskset
disp(' ');
disp('Scheduling the loop');
prob=problem('CSCH');
TS=cycsch(T, prob, m, schoptions);

plot(TS);

%Pass data to True-Time simulator
disp(' ');
disp('Generating output file for TrueTime simulation.');
delete('simple_init.m');
delete('code.m');
cssimout(TS,'simple_init.m','code.m');

disp(' ');
disp('Starting the simulation.');
if exist('ttInitKernel')
    switch(alg)
        case 1
            open cssim_dsvf_demo;
            sim('cssim_dsvf_demo');
        case 2
            open cssim_pds_demo;
            sim('cssim_pds_demo');
    end
else
    error('TrueTime is not instaled!')
end
% end .. CSSIM_DEMO
