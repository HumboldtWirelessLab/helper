function Value = subsref(schedobj,index)
%SUBSREF  SUBSREF property management in referencing operation.
%
%   SCHEDOBJ.property gets a value of the property.
% 
%   This is equivalent to calling GET method with shorter syntax.
%
%   See also GET.

%   Author(s): Michal Sojka, Michal Kutil
%   Copyright (c) 2004 CTU FEE
%   $Revision: 167 $  $Date: 2005-07-01 18:06:40 +0200 (pá, 01 VII 2005) $

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
Value = schedobj;
for i=1:len
    try
        switch index(i).type
            case '.'
                if isstruct(Value)
                    Value = getfield(Value, index(i).subs);
                else
                    Value = get(Value, index(i).subs);
                end
            case {'()','{}'}
                if isa(Value,'taskset')
                    reindexing_index = index(i).subs{1};
                    tmp_tasks = get(Value,'tasks');
                    set(Value,'tasks',{tmp_tasks{reindexing_index}});
                    tmp_Prec = get(Value,'Prec');
                    remove_tasks = setdiff(1:length(tmp_Prec),reindexing_index);
                    for i = 1:length(remove_tasks)
                        predecessors = find(tmp_Prec(:,remove_tasks(i)));
                        successors =  find(tmp_Prec(remove_tasks(i),:));
                        tmp_Prec(predecessors,successors) = 1;
                    end
                    set(Value,'Prec',tmp_Prec(reindexing_index,reindexing_index));
                elseif iscell(Value)
                    Value = {Value{index(i).subs{:}}};
                    if length(Value) == 1
                        Value = Value{1};
                    end
                else
                    Value = Value(index(i).subs{:});
                end
            otherwise
                error('Unknown indexing method');
        end % switch S.
    catch
        rethrow(lasterror)
    end
end