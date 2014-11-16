function struct = schstruct(varargin)
%SCHSTRUCT  Return empty (or add to input) schedule's structure
%
%   struct = SCHSTRUCT([struct])
%     struct - scheduling struct
%
%   See also add_schedule.

%   Author(s): M. Kutil
%   Copyright (c) 2005 CTU FEE
%   $Revision: 176 $  $Date: 2005-07-22 11:04:33 +0200 (pá, 22 VII 2005) $

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
 
struct.desc = ''; % description
struct.is = 0;    % is schedule
struct.time = [];    % solving time
struct.iterations = [];    % number of interations
struct.memory = [];    % memory allocation

%end .. @taskset/private/schstruct