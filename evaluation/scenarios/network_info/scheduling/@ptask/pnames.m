function [Props,AsgnVals,DefVal] = pnames(ptask)
%PNAMES  All public properties and their assignable values and default value
%
%   [PROPS,ASGNVALS,DEFVAL] = PNAMES(PTASK)  
%     PROPS    - list of public properties of the object PTASK (a cell vector)
%     ASGNVALS - assignable values for these properties (a cell vector)
%     DEFVAL   - default values
%
%   See also  GET, SET.

%   Author(s): M. Kutil, Michal Sojka
%   Copyright (c) 2004 CTU FEE
%   $Revision: 81 $  $Date: 2004-11-15 12:37:02 +0100 (po, 15 XI 2004) $

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
 

% Get parent object properties
[Props,AsgnVals,DefVal] = pnames(ptask.task);

% Add PTASK properties
Props = {Props{:} 'Period'}; 

% Also return assignable values if needed
if nargout > 1,
    AsgnVals = {AsgnVals{:} 'double'};

    if nargout > 2,
        DefVal = {DefVal{:} 0};
    end
end

%end .. @task/pnames
