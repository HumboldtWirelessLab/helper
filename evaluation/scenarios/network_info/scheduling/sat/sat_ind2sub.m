function [out] = sat_ind2sub (index, J, K)
%SAT_SUB2IND convert marking of boolean variable in from
%            Xm to Xijk
%
%    [i j k] = SAT_IND2SUB(index, J, K) return index of boolean variable.
%      i - task index
%      j - time
%      k - procesor index
%      m - order of boolean variable
%      J - max time
%      K - number of procesors
%
%    Index m is computed as m = (i-1)KJ+(k-1)J+j + K*(i-1)+k
%    Topology order of index m is: 1 0 1, 1 1 1, ..., 1 J 1, 1 0 2,
%      1 1 2, ..., 1 J 2, ..., 1 J K, 2 0 1, ..., 2 J 1, ..., 2 J K, ...
%
%    See also SAT_SUB2IND

%   Author(s): M. Kutil
%   Copyright (c) 2004 CTU FEE
%   $Revision: 105 $  $Date: 2005-05-04 16:14:50 +0200 (st, 04 V 2005) $

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
 
if (index <= 0)
    error('Index is less or equal zero!');
end

i = fix((index-1) / ((J+1)*K)) + 1;
k = fix(((index-1) - (i-1)*(J+1)*K) / (J+1))+1;
j = index - (i-1)*(J+1)*K - (k-1)*(J+1) -1;

out = [i j k];
% end .. sat/sat_ind2sub
