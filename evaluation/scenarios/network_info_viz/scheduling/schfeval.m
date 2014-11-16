function varargout = schfeval(varargin)
%SCHFEVAL   Scheduling internal feval (schfeval) is same as feval function,
%           but moreover you can call a functions with relativ path from
%           scheduling toolbox path.
%
%  out = schfeval(function,x1,....,xn)
%
%  example: out=schfeval('@taskset/private/base64encode.m','text')
%
%  See also feval.
%
%  For scheduling toolbox's developers only!

%   Author(s): M. Kutil
%   Copyright (c) 2005 CTU FEE
%   $Revision: 1371 $  $Date: 2007-06-22 22:52:15 +0200 (pá, 22 VI 2007) $

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

if ~isa(varargin{1}, 'function_handle')
    path_save = pwd;
    schroot = fileparts(mfilename('fullpath'));
    [fcepath, fcename, fceext] = fileparts(varargin{1});
    eval(['cd ' '''' [schroot filesep fcepath] ''''])
    try 
        nargin(fcename);
        nargout(fcename);
    catch
        eval(fcename);
        eval(['cd ' '''' path_save '''']);
        return;
    end
    eval(['varargin{1} = @' fcename ';']); 
    eval(['cd ' '''' path_save '''']);
end

if nargout >= 1 
    [varargout{1:nargout}]=feval(varargin{1},varargin{2:end});
else
    feval(varargin{1},varargin{2:end});
end
    
%end .. schfeval
