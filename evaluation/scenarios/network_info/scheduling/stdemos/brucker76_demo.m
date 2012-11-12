% brucker76_DEMO Demo application of the scheduling with 'P|in-tree,pj=1|Lmax' notation
%
%   This demo file shows how to solve a P|in-tree,pj=1|Lmax problem using
%   Bruckerr's algorithm. The tasks in taskset T are assigned to 4 identical
%   processors in order minimizing Lmax. 
%
%   see also brucker76

%   Author(s): P.Sucha
%   Copyright (c) 2007 CTU FEE


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
disp('Demo of Brucker''s algorithm for problem ''P|in-tree,pj=1|Lmax''.');
disp('------------------------------------------------------');

%load an in-tree graph
load brucker76_demo

%Conversion intree -> taskset
T=taskset(g,'n2t',@node2task,'DueDate');


disp(' ');
disp('An instance of the scheduling problem:');
get(T)


%definition of problem to be solved 
prob = problem('P|in-tree,pj=1|Lmax');

%Brucker's algorithm
TS = brucker76(T,prob,4);

%plot of the final schedule
plot(TS,'proc',1); 

%end of file

