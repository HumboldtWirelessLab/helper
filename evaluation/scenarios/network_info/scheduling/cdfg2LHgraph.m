function LHgraph = cdfg2LHgraph(cdfg,UnitProcTime,UnitLattency)
%CDFG2LHGRAPH converts CDFG to LH graph.
%    LH = CDFG2LHGRAPH(CDFG,UNITPROCTIME,UNITLATTENCY) converts Cyclic
%    Data Flow Graph CDFG to a graph LH weighted by lengths and heights.
%    Parameter UNITPROCTIME is a vector defining time to feed processors
%    (arithm. units), UNITLATTENCY is a vector specifying input-output
%    latency of processors (arithm. units).
%
%  See also CYCSCH.

%   Author(s): P. Sucha
%   Copyright (c) 2005 CTU FEE
%   $Revision: 1520 $  $Date: 2007-09-17 13:22:11 +0200 (po, 17 IX 2007) $

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

if(~isa(cdfg,'graph'))
    error('Input parametr must be a graph');
end;

[tf,loc] = ismember('Processor',cdfg.UserParam.graphedit.nodeparams);
if(loc==0)
    error('Parametr ''Processor'' is not defined in the input graph.')
end;
cdfg.UserParam.graphedit.nodeparams={'ProcTime' 'Processor'};

n=length(cdfg.N);
dedicProc=zeros(1,n);
for(i=1:n)
   dedicProc(i)=cdfg.N(i).UserParam{loc};
   if(length(UnitProcTime)<dedicProc(i))
       error(sprintf('Processing time of unit %d is not defined in parametr ''UnitProcTime''.',dedicProc(i)));
   end;
   if(length(UnitLattency)<dedicProc(i))
       error(sprintf('Input-output latency of unit %d is not defined in parametr ''UnitLattency''.',dedicProc(i)));
   end;
   cdfg.N(i).UserParam={UnitProcTime(dedicProc(i)) dedicProc(i)};
end;

H=edges2matrixparam(cdfg,1,inf);
cdfgEdges=(H~=inf);
ioLat=UnitLattency(dedicProc)'*ones(1,n);
L=cdfgEdges.*ioLat;
LHgraph=matrixparam2edges(cdfg,L,1,0);
LHgraph=matrixparam2edges(LHgraph,H,2);

%end .. cdfg2LHgraph
