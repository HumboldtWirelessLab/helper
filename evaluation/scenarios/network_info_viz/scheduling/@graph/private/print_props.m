function print_props(schedobj)
%PRINT_PROPS    Prints public properties of an object
%
%   PRINT_PROPS(SCHEDOBJ) Prints public properties of an SCHEDOBJ
%   object. Used by GET method.
%   
%   See also GET.

%   Author(s): M. Kutil, M. Sojka
%   Copyright (c) 2004 CTU FEE
%   $Revision: 674 $  $Date: 2007-03-02 09:34:43 +0100 (pá, 02 III 2007) $

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
 

val = get_props(schedobj);
prop = fieldnames(val);
for i=1:size(prop,1)
	value = getfield(val,prop{i});
	
	if ischar(value)
		value = format_char(value);
	end
	
	if iscell(value)
		if length(value)  > 1
			value = ['{' num2str(size(value,1)) 'x' num2str(size(value,2)) ' cell-array}'];
		else
			value = value{1};
			if ischar(value)
				value = ['{' format_char(value) '}'];
            elseif isnumeric(value)
				value = ['{' format_num(value) '}'];
            else
                value = ['{' num2str(size(value,1)) 'x' num2str(size(value,2)) ' cell-array}'];                
			end
		end
	end
 
	if isnumeric(value)
		value = format_num(value);	
    end
    
    if isstruct(value)
        value = ['[' num2str(size(value,1)) 'x' num2str(size(value,2)) ' struct]'];
    end
			
	disp(sprintf('\t%s%s: %s',blanks(max(cellfun('length',prop))-length(prop{i})),prop{i},value))
end

% format functions

function value = format_char(value)
    value = ['''' value ''''];

function value = format_num(value)
    if size(value,1)  > 1
		value = ['[' num2str(size(value,1)) 'x' num2str(size(value,2)) ' matrix]'];
	else
		if size(value,2)  > 1
			value = ['[' num2str(value,'%1d ') ']'];
		else
			value =  num2str(value);
		end
	end


