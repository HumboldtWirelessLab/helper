function make_cplex_ilp(mexFileDestination,schTBContribPath,operatingSystem)
%MAKE_CPLEX_ILP makefile for external CPLEX ILP solver
%
%This m-file makes external algorithms of Scheduling Toolbox. For more
%information about the external algorithms see individual documentains
%and license files. This m-file is called from main makefile (make.m)
%in Scheduling Toolbox main dirrectory.
%

%   Author(s): P. Sucha, M. Kutil
%   Copyright (c) 2005 CTU FEE
%   $Revision: 282 $  $Date: 2005-11-23 09:34:11 +0100 (st, 23 XI 2005) $

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

res = input('Do you wan to compile Matlab interface for CPLEX ILP solver(y/[n]):','s');

if(strcmp(res,'y'))

    fprintf('Extracting Matlab interface for CPLEX ILP solver: ');
	skipThisCompilation=0;
	
	%Unzip file
	try
        if(strcmp(operatingSystem,'win'))
            %system('unzip -qo cplexint9.zip');
        else
            unzip('cplexint9.zip');
        end;
		fprintf('done.\n');
	catch
        skipThisCompilation=1;
        disp(lasterr);
        disp('Can not extract ''cplexint9.zip''.');
	end;
	
    cd('cplexint');
    
    %Compile file
	if(skipThisCompilation==0)
        cplexDir=[];
        while(isempty(cplexDir))
    	    res = input('Specify CPLEX path (e.g. C:\\ILOG\\CPLEX91 or /usr/site/bin/cplex): ','s');
            if(exist(res,'dir'))
                cplexDir=res;
            else
                disp('Incorrect directory.');
            end;
        end;
        
        cplexIncDir=[cplexDir filesep 'include' filesep 'ilcplex'];
        if(strcmp(operatingSystem,'win'))
            cplexLib=[cplexDir filesep 'lib' filesep 'msvc7' filesep 'stat_sta' filesep 'cplex91.lib'];
        else
            cplexLib=[cplexDir filesep 'lib' filesep 'msvc7' filesep 'stat_sta' filesep 'cplex91.lib'];    %???
        end;
        
        try
            cmd=[' -I' cplexIncDir ' -DRELEASE_CPLEX_LIC' ' cplexint.c ' cplexLib];
            fprintf('Compiling Matlab interface for CPLEX: ');
            eval(['mex ' cmd]);
	        %mex -I'C:\ILOG\CPLEX91\include\ilcplex' cplexint.c 'C:\ILOG\CPLEX91\lib\msvc7\stat_sta\cplex91.lib'
            fprintf('done.\n');
        catch
            skipThisCompilation=1;
            disp(lasterr);
            disp('Can not compile Matlab interface for CPLEX ILP solver.');
    	end;
        
        %copy compiled files
        if(skipThisCompilation==0)
            copyfile('cplexint.dll', mexFileDestination);
        	copyfile('cplexint.m', mexFileDestination);
        end;
        
    end;
    
end;

cd(schTBContribPath);
