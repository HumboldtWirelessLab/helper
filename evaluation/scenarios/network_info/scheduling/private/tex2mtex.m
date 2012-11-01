function out=tex2mtex(in)
%TEX2MTEX   Reduce tex string to tex string acceptable by matlab
%
% Description
%    out=TEX2MTEX(in)
%      in  - input string
%      out - output reduced string

%   Author(s):  M. Kutil
%   Copyright (c) 2007 CTU FEE
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

if iscell(in)
    for i = 1:length(in)
        out{i} = strreduce(in{i});
    end
else
    out = strreduce(in);
end



function out = strreduce(in)

if ~ischar(in)
    error('TORSCHE:invalidDataTypes', 'Input string must be a string data type.');
end

if length(in) > 0
    if (in(1) == '$') && (in(end) == '$')
        in = in(2:end-1);
    end

    if ~mod(sum(in == '$'),2)
        in = in(in ~= '$');
    end
end
out = in;