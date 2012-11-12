function val = get_props(SCHEDOBJ)
%GET_PROPS  Returns structure of SCHEDOBJ properties.
%
%   VAL = GEN_STRUCT(SCHEDOBJ,AllProps) returns the structure
%   containing all object properties.
%   
%   NOTE: this is an internal function which is used by the GET
%   method. Don't call this method yourself.

% $Revision: 727 $ $Date: 2007-03-13 16:34:55 +0100 (út, 13 III 2007) $

% This version is used in this base class only. Inherited classes
% should use a diferent version of this method.


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
 
% val = struct(SCHEDOBJ);
% prop = fieldnames(SCHEDOBJ);
try
    AllProps = pnames(SCHEDOBJ,1);
catch
    AllProps = pnames(SCHEDOBJ);
end

for i=1:length(AllProps)
    eval (['val.' AllProps{i} '= get(SCHEDOBJ,''' AllProps{i} ''');']);
end

% if ~isfield(val, 'parent')              % Base class (no parent)
%     for i=1:length(prop),
%         if ~sum(strcmpi(AllProps,prop{i}))
%             val = rmfield(val, prop{i});  
%         end
%     end
% else                                    % Child classes
%     val_me = val;
%     val = get(getfield(val, val.parent));
%     for i=1:length(prop),
%         if sum(strcmpi(AllProps,prop{i}))
%             val = setfield(val, prop{i}, getfield(val_me, prop{i}));  
%         end
%     end
% end % if ~isfield(val,    

%end .. @schedobj/get_props
