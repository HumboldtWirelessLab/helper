function [TS] = algprjdeadlinepreccmax(T,prob,m)
% ALGPRJDEADLINEPRECCMAX computes schedule for P|rj,prec,~dj|Cmax problem
%
% Synopsis
%   TS = algprjdeadlinepreccmax(T, problem, No_proc)
%
% Description
%	TS = algprjdeadlinepreccmax(T, problem, No_proc) finds schedule to the
%   scheduling problem 'P|rj,prec,~dj|Cmax'.
%   Parameters: 
%     T:
%       - input set of tasks
%     TS:
%       - set of tasks with a schedule,
%     PROBLEM: 
%       - description of scheduling problem (object PROBLEM) -
%	      'P|rj,prec,~dj|Cmax'
%     No_proc:
%       - number of processors for scheduling
%
% See also PROBLEM/PROBLEM, TASKSET/TASKSET, ALGPCMAX, CYCSCH.

%   Author(s): M. Silar, P. Sucha
%   Copyright (c) 2007 CTU FEE

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

if ~all(T.Deadline-T.ReleaseTime-T.ProcTime >= 0)
    error('Wrong input data');
end

if ~(is(prob,'alpha','P') && is(prob,'betha','rj,prec,~dj') && is(prob,'gamma','Cmax') & (m > 0))
    error('This problem can''t be solved by this algorithm or number of processors is smaller than zero');
end

numberOfTasks = size(T);

maxT = scheduleLength(T,m);

A = zeros(numberOfTasks,maxT*m*numberOfTasks);

for i=0:numberOfTasks-1
    A(i+1,(1+i*maxT*m):((i*maxT*m)+maxT*m))=1;
end

for i=1:numberOfTasks
    t = T.procTime(i);
    pom = zeros(maxT*m,maxT*m);
    for u=1:maxT*m
        if u-t+1 > 0
            pom(u,(u-t+1):u)=1;
        else
            pom(u,1:u)=1;
        end
    end
    if i==1
        vysl=pom;
    else
        vysl=[vysl,pom];
    end
end
A=[A;vysl];

ready = zeros(numberOfTasks,maxT*m*numberOfTasks);
pom = 0;
for i=1:numberOfTasks
    for v=1:m
        ready(i,(v-1)*maxT+1+(i-1)*maxT*m:v*maxT+(i-1)*maxT*m)=0:maxT-1;
    end
end
A=[A;ready;ready];

b = 1;
ctype='E';
for i=1:numberOfTasks-1
    b=[b;1];
    ctype = [ctype,'E'];
end
for i=1:maxT*m
    b = [b;1];
    ctype = [ctype,'L'];
end
for i=1:numberOfTasks
    b = [b;T.ReleaseTime(i)];
    ctype = [ctype,'G'];
end
for i=1:numberOfTasks
    b = [b;T.Deadline(i)-T.ProcTime(i)];
    ctype = [ctype,'L'];
end

for i=1:maxT-1
    pom=[pom;i];
end
pom2 = [];
for i=1:m
    pom2=[pom2;pom];
end
c=[];

for i=1:numberOfTasks
    pom3(:,1)=pom2(:,1)+T.ProcTime(i);
    c=[c;pom3];
end

for x=1:size(T.prec,1)
    for y=1:size(T.prec,2)
        if T.prec(x,y) == 1
            pom2 = zeros(1,maxT*m*numberOfTasks);
            for i=1:numberOfTasks*m
                if i==x
                    for v=1:m
                        pom2((i-1)*maxT*m+(v-1)*maxT+1:(i-1)*maxT*m+v*maxT)=pom;
                    end
                elseif i==y
                    for v=1:m
                        pom2((i-1)*maxT*m+(v-1)*maxT+1:(i-1)*maxT*m+v*maxT)=-pom;
                    end
                end
            end
            A=[A;pom2];
            b=[b;-T.ProcTime(x)];
            ctype = [ctype,'L'];
        end
    end
end

ctype = ctype';
lb = zeros(1,maxT*m*numberOfTasks)';
ub = ones(1,maxT*m*numberOfTasks)';
vartype = 'I';
for i=1:maxT*m*numberOfTasks-1
    vartype = [vartype;'I'];
end
sense=1;
schoptions=schoptionsset('ilpSolver','glpk','solverVerbosity',0);

[xmin,fmin,status,extra] = ilinprog (schoptions,sense,c,A,b,ctype,lb,ub,vartype);
if status~=1
    display('LP sollution cant be foud');
    return;
end

for i=1:numberOfTasks
    proces(i,:) = xmin(1+maxT*m*(i-1):maxT*m*i);
end

s = zeros(1,numberOfTasks);
procesor = zeros(1,numberOfTasks);
for i=1:numberOfTasks
    for v=1:m
        pom = proces(i,1+maxT*(v-1):maxT*v);
        if sum(pom)~=0
            procesor(i)=v;
        end
        for w = 1:maxT
            s(i)=s(i)+pom(w)*(w-1);
        end
    end
end

description = 'Optimal schedule by ILP';
add_schedule(T,description,s,T.ProcTime,procesor);

TS = T;

end


%--------------------------------------------------------------------------
%Function scheduleLength is used to evaluate a upper bound for ILP
function scheduleLength = scheduleLength(T,m)

n=length(T.Name);           %pocet uloh

%Pomocne promenne
t=zeros(1,m);               %disponibility time of processor
s=inf*ones(1,n);            %start of executing tasks
processorSchedule=zeros(1,n);  %vector of assignment tasks to processor
startCondition = inf(1,n);

[p,list] = sort(T.Deadline);
numberOfTasks = size(T);
maxT = sum(T.ProcTime);

for i=1:n
    if ( T.Prec(:,i) == zeros(n,1))
        startCondition(i) = 0;
    end;
end;
ammountOfScheduled = 0;
t_index = 1;
while ((ammountOfScheduled ~= numberOfTasks)&&(t(t_index)<=maxT))
    %Choosing processor
    [t_hodn,t_index] = min(t);
    %Choosing task
    x = 0;
    test = false;
    while((test == false)&&(x < numberOfTasks))
        x= x+1;
        if ((startCondition(list(x)) ~= Inf)&&(startCondition(list(x)) ~= -Inf)&&(startCondition(list(x))<= t_hodn)&&(T.ReleaseTime(list(x))<= t_hodn))
            actual_task = list(x);
            test = true;
        end;
    end;

    if test == true
        %Schedule task
        s(actual_task) = t_hodn;
        processorSchedule(actual_task) =  t_index;
        t(t_index)= t_hodn + T.procTime(actual_task);
        startCondition(actual_task) = -Inf;
        ammountOfScheduled = ammountOfScheduled + 1;

        for i=1:n
            if (sum(T.Prec(actual_task,:) == zeros(1,n)) < n)
                for v=1:n
                    if(T.Prec(actual_task,v) == 1);
                        startCondition(v) = t(t_index);
                    end
                end
            end;
        end;
    else
        t(t_index)=t(t_index)+1;
    end
end;
scheduleLength=max(t);
end


%end of file
