function object = set_helper(object, property, value)
%SET_HELPER Internal function for property setting.
%
%    SET_HELPER(OBJECT, PROPERTY, VALUE) sets PROPERTY of an OBJECT to
%    the VALUE.
%    
%    This function has to be copied to every descendant of SCHEDOBJ
%    class. Matlab's OOP behavior is very limited and this function
%    allows us to overcome some of these limations.
%
%    See also: SET

%   Author(s): Michal Sojka
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
 

if (isfield(struct(object), property))
    eval(['object.' property '=value;']);
else
    eval(['object.' object.parent ' = set_helper(object.' object.parent ', property, value);']);
end    
