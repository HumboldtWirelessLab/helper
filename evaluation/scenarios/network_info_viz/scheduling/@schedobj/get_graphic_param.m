function out=get_graphic_param(obj, varargin)
%GET_GRAPHIC_PARAM gets graphics params for object drawing
%
%Synopsis
%    GET_GRAPHIC_PARAM(OBJ,C):
%
%Description
% GET_GRAPHIC_PARAM(OBJ,Parameter) return graphic parameters where:
%  OBJ:
%    - object
%  Parameter:
%    - name of parameter from the following set
%
%  Available parameters:
%   color:
%     - color
%   x:
%     - X coordinate
%   y:
%     - Y coordinate
%
% See also SCHEDOBJ/SET_GRAPHIC_PARAM.

%   Author(s):  M. Kutil
%   Copyright (c) 2004 CTU FEE
%   $Revision: 1750 $  $Date: 2007-09-20 11:07:47 +0200 (čt, 20 IX 2007) $

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

objectname = inputname(1);
if isfield(struct(obj),'parent')
    objs = struct(obj);
    objparent = getfield(objs,objs.parent);
    out=get_graphic_param(objparent, varargin{:});
else
    ni = length(varargin);
    if (ni~=1)
        error('Invalid count of input parameters.');
    end 
    switch lower(varargin{1})
        case 'x'
            out=obj.GrParam.position(1);
        case 'y'
            out=obj.GrParam.position(2);
        otherwise
            if isfield(obj.GrParam,lower(varargin{1}))
                out=getfield(obj.GrParam,lower(varargin{1}));
            else
                error('Unknown parametr!');
            end
    end
end
%end .. @schedobj/get_graphic_param
