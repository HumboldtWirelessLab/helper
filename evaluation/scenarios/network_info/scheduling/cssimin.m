function [T,m] = cssimin(filename,varargin)
%CSSIMIN Cyclic Scheduling Simulator - input parser.
%
% Synopsis
%   T=cssimin(filename)
%   T=cssimin(filename,schoptions)
%   
% Description
%   The function creates taskset T from input file describing cyclic
%   scheduling problem. Input parameters are:
%   filename:
%              - specification file
%   schoptions:
%              - optimization options (See SCHOPTIONSSET)
%
% Example
%   For more delails see User's Guide [guide:sec-cssim].
%
%   See also CYCSCH, SCHOPTIONSSET.


%   Author(s): D.Matejicek, P.Sucha
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


%Parse input file.
[H,g,u,p,l,Variables,Functions,Processors,CodeGenerationTaskParam,SimulationFrequency]=cssimparser(filename);

%Create corresponding graph
gr=graph('adj',double(g~=Inf));
gr=matrixparam2edges(gr,g);

gr.UserParam.graphedit.nodeparams={'Processor'};
for(i=1:size(H,1))
    gr.N(i).Name=sprintf('%s%d','T',i);
    gr.N(i).UserParam={u(i)};
end;

LHgraph = cdfg2LHgraph(gr,p',l');

%Generate taskset from graph 'LHgraph'.
gen_taskset=taskset(LHgraph,'n2t',@node2task,'ProcTime','Processor','e2p',@edges2param);
%gen_taskset = taskset(LHgraph);

%Add informations obtained by parser to 'TSUserParam'
if(size(Processors,2)>0)
    gen_taskset.TSUserParam.CodeGenerationData.Processors=Processors;
end
if(size(Variables,2)>0)
    gen_taskset.TSUserParam.CodeGenerationData.Variables=Variables;
end
if(size(Functions,2)>0)
    gen_taskset.TSUserParam.CodeGenerationData.Functions=Functions;
end
gen_taskset.TSUserParam.CodeGenerationData.SimulationFrequency=SimulationFrequency;

for(i=1:size(CodeGenerationTaskParam,2))
    gen_taskset.tasks(i).UserParam.CodeGenerationTaskParam=CodeGenerationTaskParam(i);
end

T=gen_taskset;

m=[];
for i=1:length(Processors)
    m=[m Processors(i).Number];
end;

%end of file
