function gOut = horzcat(varargin)
%HORZCAT      Concatenation of graph.
%                   G = [G1 G2 G3 ... ]
%
%  See also GRAPH.

%   Author(s): V. Navratil
%   Copyright (c) CTU FEE
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

ni = nargin;
if  isa(varargin{1},'graph') && ni == 1
    gOut = varargin{1};
elseif ni > 1
    g1 = varargin{1};
    g2 = varargin{2};
    if isequal(g1.DataTypes,g2.DataTypes)
        gOut = g1;
        gOut.N = [g1.N g2.N];
        gOut.E = [g1.E g2.E];
        g2.eps = g2.eps + length(g1.N);
        gOut.eps = [g1.eps; g2.eps];
        varargin{2} = gOut;
        gOut = horzcat(varargin{2:end}); % Recursion
    else
        error('There are various UserParams among ordered graphs.');
        return;   
    end
end


%end .. @graph/horzcat

