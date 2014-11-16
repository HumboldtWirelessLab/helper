function [Props,AsgnVals,DefVal] = pnames(taskset, varargin)
%PNAMES  All public properties and their assignable values and default
%           value
%
%   [PROPS,ASGNVALS,DEFVAL] = PNAMES(TASKSET[,virtualprop])
%     PROPS       - list of public properties of the object TASKSET (a cell vector)
%     ASGNVALS    - assignable values for these properties (a cell vector)
%     DEFVAL      - default values
%     virtualprop - if is set to 1 than returned values includes a virtual
%                   property
%
%   See also  GET, SET.

%   Author(s): M. Kutil
%   Copyright (c) 2004 CTU FEE
%   $Revision: 154 $  $Date: 2005-06-14 08:28:32 +0200 (út, 14 VI 2005) $

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
[Props,AsgnVals,DefVal] = pnames(getfield(struct(taskset), taskset.parent));

% TASKSET properties
Props = {'Prec' 'ScheduleDesc' 'TSUserParam' Props{:}}; 
% There are also dynamic properties.  See GET_VPROP.

% Get virtual properties
if ~isempty(varargin) & varargin{1} == 1
    [VProps,VAsgnVals,VDefVal] = pnames(task(1));
    for i = 1 : length(VProps);
        if find(strcmp(VProps(i),Props))
            VProps = [VProps(1:i-1) VProps(i+1:length(VProps))];
            VAsgnVals = [VAsgnVals(1:i-1) VAsgnVals(i+1:length(VAsgnVals))];
            VDefVal = [VDefVal(1:i-1) VDefVal(i+1:length(VDefVal))];
        end
    end
else
    VProps = {}; VAsgnVals = {}; VDefVal ={};
end

Props = {Props{:} VProps{:}};


% Also return assignable values if needed
if nargout>1,
    AsgnVals = {'precedens constrains' ...
                'schedule description'...
                'taskset user parameters'...
                AsgnVals{:} VAsgnVals{:}};

    if nargout>2,
        DefVal = {[] '' [] DefVal{:} VDefVal{:}};
    end
end

%end .. @taskset/pname