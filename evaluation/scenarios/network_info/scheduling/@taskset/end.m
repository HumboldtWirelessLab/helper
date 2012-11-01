function e_val = end(TS,k,n);
%END Last index in tsekset object
%
%    END(TS,K,N) is called for indexing expressions involving the 
%    object A when END is part of the K-th index out of N indices.

%   Author(s):  M. Kutil
%   Copyright (c) 2005 CTU FEE
%   $Revision: 160 $  $Date: 2005-06-28 08:15:48 +0200 (út, 28 VI 2005) $

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
 
if n==1
    e_val = size(TS);
else
    e_val = 1;
end
%end .. @taskset/end
