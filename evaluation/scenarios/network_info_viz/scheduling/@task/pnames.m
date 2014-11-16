function [Props,AsgnVals,DefVal] = pnames(task)
%PNAMES  All public properties and their assignable values and default
%           value
%
%   [PROPS,ASGNVALS,DEFVAL] = PNAMES(TASK)  
%     PROPS    - list of public properties of the object TASK (a cell vector)
%     ASGNVALS - assignable values for these properties (a cell vector)
%     DEFVAL   - default values
%
%   See also  GET, SET.

%   Author(s): M. Kutil
%   Copyright (c) 2004 CTU FEE
%   $Revision: 119 $  $Date: 2005-05-16 08:56:08 +0200 (po, 16 V 2005) $

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
[Props,AsgnVals,DefVal] = pnames(getfield(struct(task), task.parent));

% Add TASK properties
Props = {'Name' 'ProcTime' 'ReleaseTime' 'Deadline' 'DueDate' 'Weight' 'Processor' 'UserParam' Props{:}}; %'ALAP' 'ASAP'

% Also return assignable values if needed
if nargout>1,
    
    AsgnVals = {'name of the TASK' ...
                'processing time' ...
                'release time (arrival time)' ...
                'deadline' ...
                'duedate' ...
                'weight (priority)' ...
                'dedicated processor' ...
                'user parameters' ...
                AsgnVals{:}};
        
%                 'ALAP AsLateAsPosible' ...
%                 'ASAP AsSonAsPosible' ...


    if nargout>2,
        DefVal = {''  -inf  0  inf  inf  1 [] [] DefVal{:}};
    end
end

%end .. @task/pnames
