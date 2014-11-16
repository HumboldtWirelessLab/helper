function make
%MAKE makefile for external algorithms  
%
%This m-file makes external algorithms of Scheduling Toolbox. For more
%information about the external algorithms see individual documentains
%and license files. This m-file is called from main makefile (make.m)
%in Scheduling Toolbox main dirrectory.
%

%   Author(s): P. Sucha, M. Kutil
%   Copyright (c) 2005 CTU FEE
%   $Revision: 1676 $  $Date: 2007-09-19 08:34:11 +0200 (st, 19 IX 2007) $

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

fprintf('Compiling external utilities/solvers.\n');

[str,maxsize,endian] = computer;
switch(str)
    case 'PCWIN'
        operatingSystem='win';
    otherwise
        operatingSystem='linux';
end;
fprintf('Current system is: %s.\n',operatingSystem);

schTBContribPath=pwd;
mexFileDestination = regexprep(schTBContribPath,'contrib$','');
mexFileDestination = mexFileDestination(1:end-1);
mexFileDestination = [mexFileDestination filesep 'private'];


%Make GLPK ILP solver
make_glpk_ilp(mexFileDestination,schTBContribPath,operatingSystem);

%Make CPLEX ILP solver Matlab interface
%make_cplex_ilp(mexFileDestination,schTBContribPath,operatingSystem);

%Make MATLABXML interface
make_matlabxml(mexFileDestination,schTBContribPath,operatingSystem);

% end .. MAKE
