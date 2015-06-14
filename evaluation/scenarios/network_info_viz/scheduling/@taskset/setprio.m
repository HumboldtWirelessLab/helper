function setprio(TS, rule)
%SETPRIO  sets priority (weight) of tasks acording to some rules.
%
%Synopsis
%  SETPRIO(T, RULE)
%
%Description
% Properties:
%  T:
%    - set of tasks
%  RULE:
%    - 'rm' rate monotonic
%
% See also PTASK/PTASK

%   Author(s): Michal Sojka
%   Copyright (c) 2004 CTU FEE
%   $Revision: 1764 $  $Date: 2007-09-20 15:07:57 +0200 (čt, 20 IX 2007) $

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
 

objectname = inputname(1);
if isempty(objectname),
    error('First argument to SETPRIO must be a named variable.')
end

switch rule
  case 'rm'
    TS = setprio_rm(TS);
  otherwise
    error('Unknown rule parameter');
end
assignin('caller',objectname,TS)
