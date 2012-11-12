function cssimout(T,ttinifile,ttcodefile)
%CSSIMOUT Cyclic Scheduling Simulator - True-Time interface.
%
% Synopsis
%   cssimout(T,ttinifile,ttcodefile)
%   
% Description
%   The function generates m-files for True-Time simulator. Input parameters are:
%   T:
%              - taskset with a cyclic schedule and parsed code in
%              'TSUserParam'
%   ttinifile:
%              - filename of True-Time initialization file
%   ttcodefile:
%              - filename of True-Time code file
%
%   See also CSSIMIN.


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


[start, lenght, processor, is_schedule] = get_schedule(T);
if(is_schedule == 0)
    error('There is not schedule in the taskset.');
end

if(~isfield(T.TSUserParam,'CodeGenerationData'))
    error('Informations about parsed algorithm are not contained in ''TSUserParam''.');
end

xmlsave('xmlfile.xml',T);
xslt('xmlfile.xml','acgmtruetime.xsl',ttcodefile);
xslt('xmlfile.xml','acgmtruetimeinit.xsl',ttinifile);

%end of file
