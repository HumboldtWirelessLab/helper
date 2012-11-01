function [Value] = get_correction(taskset,Property,Value)
%GET_CORRECTION  Corection for automatic solved data from sched obj.
%
%   VALUE = GET_CORRECTION(TASKSET,'PropertyName','Value') returns 
%    repaired the value of the specified virtual property of 
%    the TASKSET.
% 
%   NOTE: This function is for internal use only. Use GET instead.
%   
%   See also GET.

%   Author(s): M. Kutil
%   Copyright (c) 2004 CTU FEE
%   $Revision: 108 $  $Date: 2005-05-04 16:22:24 +0200 (st, 04 V 2005) $

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
 
switch lower(Property)
  case 'prec'  % lower case
    S = full(Value);
    [i,j,s] = find(S);
    m = max(length(S),size(taskset));
    S = sparse(i,j,s,m,m);
    Value = full(S);
    return;
end

%end .. @task/get_correction
