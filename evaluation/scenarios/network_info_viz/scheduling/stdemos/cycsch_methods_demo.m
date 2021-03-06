%CYC_SCH_METHODS_DEMO Demo application of the cyclic scheduling on
%    set of dedicated processors. It shows an comparison of
%    'integer' and 'binary' methods.
%
%    See also CYCSCH

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
disp('Comparison of ''integer'' and ''binary'' cyclic scheduling method');
disp('-------------------------------------------------------------');
disp(' ');

n=8;
exper=5;
fprintf('Experiments are generated in a random manner for %d experiments containing %d tasks.\n',exper,n);

UnitProcTime=[1];
UnitLattency=[4];
m = [1];
fprintf('\nProcessing time of the unit is %d [clk].\n',UnitProcTime);
fprintf('Input-output lattency of the unit is %d [clk].\n\n',UnitLattency);

experTime=zeros(exper,2);

for(expCounter=1:exper)
	cdfg=randdfg(n,1,3,round(n*1.8),round(n/1.5),2);
	
    LHgraph = cdfg2LHgraph(cdfg,UnitProcTime,UnitLattency);	
	
	%gen_taskset=taskset(LHgraph);
    gen_taskset=taskset(LHgraph,'n2t',@node2task,'ProcTime','Processor','e2p',@edges2param);
	%gen_taskset.ProcTime=UnitProcTime(dedicProc);
	prob=problem('CSCH');
	
    fprintf('Experiment %d of %d\n',expCounter,exper);
	%fprintf('*** Cyclic Scheduling algorithm (integer method) ***\n');
	schoptions=schoptionsset('cycSchMethod','integer','ilpSolver','glpk','verbose',0,'qmax',1);
	t_integer=cycsch(gen_taskset, prob, m, schoptions);
	
	%fprintf('\n*** Cyclic Scheduling algorithm (binary method) ***\n');
	schoptions=schoptionsset('cycSchMethod','binary','ilpSolver','glpk','verbose',0,'qmax',1);
	t_binary=cycsch(gen_taskset, prob, m, schoptions);
    
    experTime(expCounter,1)=schparam(t_integer,'time');
    experTime(expCounter,2)=schparam(t_binary,'time');
end;

b=bar(experTime);
title('Comparison of ''integer'' and ''binary'' cyclic scheduling method');
xlabel('experiment number [-]');
ylabel('CPU time [s]');
legend([b],'integer method','binary method')

meanExperTime=mean(experTime);
fprintf('\nAverage CPU time for ''integer'' method is %d [s]\n',meanExperTime(1));
fprintf('Average CPU time for ''binary'' method is %d [s]\n',meanExperTime(2));

% end .. CYC_SCH_METHODS_DEMO
