function make
%MAKE Scheduling Toolbox general makefile
%
%Use this m-file to compile Scheduling Toolbox mex-files
%

%   Author(s): P. Sucha, M. Kutil
%   Copyright (c) 2005 CTU FEE
%   $Revision: 1722 $  $Date: 2007-09-19 16:26:56 +0200 (st, 19 IX 2007) $

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

% TODO  - First call contrib directory
%       - Path check -> ask -> Set ( scheduling, scheduling/stdemos, ...? )
%       - Compilation option - SAT, ILP, ...

%clear all;
clc;
clear mex;
d=dir;

for(i=1:length(d))
    if(d(i).isdir==1)
        if(exist(['.' filesep d(i).name filesep 'make.m'],'file') & ~strcmp(d(i).name,'.') & ~strcmp(d(i).name,'..'))
            fprintf('\nEntering directory ''%s''.\n',d(i).name);
            for idash=1:length(d(i).name) fprintf('-'); end
            fprintf('----------------------\n');
            cd(d(i).name);
            try
                runmake;
            catch
                errorsend=lasterror;
                disp(errorsend.message);
            end
            cd('..');
        end;
    end;
end;

% Local make
% ----------

% P-CODE
%pcode graphedit.m
%pcode private/ge_*.m

% end .. MAKE

function runmake
make;