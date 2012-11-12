function schedobj = subsasgn(schedobj,index, val)
%SUBSASGN  SUBSASGN property management in referencing operation.
%
%   SCHEDOBJ.property = VALUE sets a value of the property.
% 
%   This is equivalent to calling SET method with shorter syntax.
%
%   See also SET.

%   Author(s): Michal Sojka, Michal Kutil
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

len = length(index);
try
switch index(1).type
    case '.'
        if (len == 1)
            set(schedobj, index(1).subs, val);
        else
            index_next=index(2:length(index));
            data = get(schedobj,index(1).subs);  
            data_all = data;
            part = 0;
            if (index_next(1).type == '()') & (length(index_next)>1)
                if iscell(data) 
                    part = index_next(1).subs{1};
                    data = data{index_next(1).subs{1}};
                    index_next=index_next(2:length(index_next));
                end  % write for array
            end
            data=subsasgn(data, index_next, val);
            if part > 0
                if iscell(data_all)
                    data_all{part} = data;
                    data = data_all;
                end
            end
            set(schedobj, index(1).subs, data);
        end
    case '()'
        if isa(schedobj, 'double')
            eval(['schedobj = ', class(val), ';']);
        end
        if (len == 1)
            if iscell(schedobj)
                schedobj{index(1).subs{1}}=val;
            else
                schedobj(index(1).subs{1})=val;
            end
        else
            index_next=index(2:len);
            schedobj(index(1).subs{1}) = subsasgn(schedobj(index(1).subs{1}), index_next, val);
        end
    otherwise
        error('Unknown indexing method');
end % switch S.
catch
    rethrow(lasterror);
end

%end .. @schedobj/subsasgn