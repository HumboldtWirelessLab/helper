function schedobj = schedobj()
%SCHEDOBJ  Creation of object schedobj.
%
%  Creation:
%    schedobj = SCHEDOBJ() creates a schedobj

%   Author(s): M. Kutil, Michal Sojka
%   Copyright (c) 2004 CTU FEE
%   $Revision: 95 $  $Date: 2004-12-01 21:05:32 +0100 (st, 01 XII 2004) $

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
 

% Create the structure

% Fields should start with capital letter if they are directly
% accessible via GET and SET method. See also PNAMES.
schedobj = struct(...
	'Notes', '',...
	'version', 0.01,...
    'GrParam',grparam);

% Label schedobj as an object of class SCHEDOBJ
schedobj = class(schedobj, 'schedobj'); 

%end .. @schedobj/schedobj
