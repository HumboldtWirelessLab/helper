function make_matlabxml(mexFileDestination,schTBContribPath,operatingSystem)
%MAKE_MATLABXML makefile for external MatlabXML tool
%
%This m-file makes external algorithms of Scheduling Toolbox. For more
%information about the external algorithms see individual documentains
%and license files. This m-file is called from main makefile (make.m)
%in Scheduling Toolbox main dirrectory.
%

%   Author(s): P. Sucha, M. Kutil
%   Copyright (c) 2005 CTU FEE
%   $Revision: 287 $  $Date: 2005-11-29 15:11:35 +0100 (út, 29 XI 2005) $

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

fprintf('Extracting MatlabXML toolbox: ');

%Unzip file
try
    if(strcmp(operatingSystem,'win'))
        system('unzip -qo matlabxml.zip');
    else
        unzip('matlabxml.zip');
    end;
    fprintf('done.\n');
catch
    disp(lasterr);
    disp('Can not extract ''matlabxml.zip''.');
end;

cd(schTBContribPath);
