function make
%MAKE makefile for SPNTL algorithm
%

%   Author(s): P. Sucha
%   Copyright (c) 2005 CTU FEE
%   $Revision: 390 $  $Date: 2006-03-24 09:02:47 +0100 (pá, 24 III 2006) $

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

fprintf('Compiling SPNTL_BAB: ');
clear spntl_bab
cmd = ['-outdir ..' filesep 'private spntl_bab.c spntl_candidates.c spntl_vexplor.c'];
eval(['mex ' cmd]);
fprintf('done.\n');

% end .. MAKE
