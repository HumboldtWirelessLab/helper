function TS=coffmangraham(T, prob, varargin)
%COFFMANGRAHAM is scheduling algorithm (Coffman and Graham)
%   for P2|prec,pj=1|Cmax problem
%
%Synopsis
%       TS = COFFMANGRAHAM(T, prob)
%       TS = COFFMANGRAHAM(T, prob, verbose)
%       TS = COFFMANGRAHAM(T, prob, options)
%
%Description
%    The function finds schedule of the scheduling problem 'P2|prec,pj=1|Cmax'.
%    Meaning of the input and output parameters is summarized below:
%       T:
%         - set of tasks, taskset object with precedence constrains
%       prob:
%         - problem P2|prec,pj=1|Cmax
%       verbose:
%         - level of verbosity
%             0 - no information (default);
%             1 - display scheduling information
%       options:
%         - global scheduling toolbox variables (SCHOPTIONSSET)
%
%See also HU, SCHOPTIONSSET, ALGPCMAX, BRUCKER76.

%   Author(s): M. Kutil, J. Martinsky, Q. Herczeg
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

verbose=0;
%do checks
if ~isa(T,'taskset')
    error('Taskset class must be taskset');
end
if nargin>2
    if isa(varargin{1},'struct')
        verbose=varargin{1}.verbose;
    elseif isa(varargin{1},'double')
        verbose=varargin{1};
    end
end
if isa(prob,'problem')
    if ~(is(prob,'alpha','P2') && is(prob,'betha','prec,pj=1') && is(prob,'gamma','Cmax'))
        error('This problem can''t be solved by coffmangraham algorithm.');
    end
else
    error('Problem must be of type problem. p=problem(P2|prec,pj=1|Cmax)');
end
if sum(sum(T.prec))==0
    warning('Precedence constrains not specified.');
end
%init
prec = T.prec;
lprec = prec;
n = length(prec);
labels = zeros(1,n);

if sum(T.proctime==ones(1,n))~=n
    error('Processing time of tasks must be 1');
end

%select immediate successors
issuc=find(sum(prec,2)==0);
%give label 1 to one issuc
labels(issuc(end))=1;
%zeros all predecesors
lprec(:,issuc(end))=0;
%mark by inf labeled task
lprec(issuc(end),issuc(end))=inf;

if verbose==1
    disp('=== Coffman and Graham algorithm ===');
    disp('start');
    disp(['task : ',num2str(1:n)]);
    disp(['label: ',num2str(labels)]);
end

j=1;
time=cputime;
while j<n
    %select predecesors of labeled tasks
    S=find(sum(lprec,2)==0);    
    if verbose==1
        disp('====================================');
        disp(['step ',int2str(j)]);
        disp(['predecessors of labeled S: ',num2str(S')]);
        msg='';
    end
    %find task with lexographicaly smallest successors    
    lmin=[];
    max=0;
    p=0;
    for i=1:length(S)
        %find successors
        l=find(prec(S(i),:)==1);
        if verbose==1
            msg=[msg,'[',num2str(l),']'];
        end            
        if isempty(l)
            l=[0];
        else
            l=labels(l);
        end;
        %sort successors
        l=sort(l,'descend');
        cl=length(l);
        if cl>max
            lmin(max+1:cl)=inf;
            max=cl;
        else            
            l(cl+1:max)=0;
        end
        %compare with lmin
        comp = (lmin<l)-(lmin>l);
        %find sign
        sign = comp(find(comp~=0));
        if isempty(sign) sign=[0];
        end
        if(sign(1)<0)
           lmin=l;
           p=i;
        end
    end;
    %add label
    labels(S(p))=j+1;    
    if verbose==1
        disp(['S successor''s labels L: ',msg]);
        disp(['task : ',num2str(1:n)]);
        disp(['label: ',num2str(labels)]);
    end
    %zeros all predecessors    
    lprec(:,S(p))=0;
    %mark by inf labeled task
    lprec(S(p),S(p))=inf;
    j=j+1;    
end;
T.UserParam = labels;
%apply Hu algorithm
TS = hu(T,prob, 2, verbose);
%add schedule results
add_schedule(TS,'time',cputime - time);
add_schedule(TS,'description','Coffman and Graham algorithm for P2|prec,pj=1|Cmax');
