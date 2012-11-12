%COMPILEDIR compiles selected files into mex-file.  
%
%COMPILEDIR(source,include,output,libFiles,extraParam) compiles files
%in path defined by cell of strings 'source' to mex-file 'output'.
%Ceil of strings 'include' specifies directories to search for #include files.
%String 'libFiles' specifies libraries for linking and string 'extraParam'
%specifies MEX compiler extra parameters.
%
%    See also SCHEDULING/MAKE
%

%   Author(s): P. Sucha, M. Kutil
%   Copyright (c) 2005 CTU FEE
%   $Revision: 564 $  $Date: 2006-11-01 19:06:24 +0100 (st, 01 XI 2006) $

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


function compileDir(source,include,output,libFiles,extraParam)

riginalPath=pwd;
sourceFiles=[];

if(~isa(source,'cell'))
    source={source};
end;

for(j=1:length(source))
	files=dir(source{j});
	
	for(i=1:length(files))
        [start,finish] = regexpi(files(i).name,'\.((c)|(cpp))$');
        if(~isempty(start))
            if(j==1)
                sourceFiles=[sourceFiles ' ' files(i).name];
            else
                sourceFullParh=[source{j} filesep files(i).name];
                sourceFiles=[sourceFiles ' ' '''' sourceFullParh  ''''];
            end;
        end;
	end;
end;
%disp(sprintf('Compiled files: %s',sourceFiles));
    
    
if(~isa(include,'cell'))
    include={include};
end;

incPaths=[];
for(i=1:length(include))
    incPaths=[incPaths ' -I' '''' include{i} '''' ];
end;

eval(['cd ' '''' source{1} '''']);
cmd=[extraParam ' -outdir ' '''' source{1} '''' ' ' incPaths ' '  sourceFiles ' ' libFiles  ' -output ' output];
eval(['mex ' cmd]);
%eval(['mduild ' cmd]);

eval(['cd ' '''' riginalPath '''']);
%end of compileDir
