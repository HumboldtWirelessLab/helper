function [TS] = bratley(taskset, prob)
% BRATLEY computes schedule by algorithm described by Bratley
%
% Synopsis
%   TS = BRATLEY(T, problem)
%
% Description
%	TS = BRATLEY(T, problem) finds schedule of the scheduling 
%      problem '1|rj,~dj|Cmax'.
%    Parameters:
%     T:
%      - input set of tasks
%     TS:
%      - set of tasks with a schedule
%     PROBLEM:
%      - description of scheduling problem (object PROBLEM)'1|rj,~dj|Cmax'
%
% See also PROBLEM/PROBLEM, TASKSET/TASKSET, ALG1RJCMAX, SPNTL.

%   Author(s): R.Capek, P. Sucha
%   Copyright (c) 2006 CTU FEE
%   $Revision: 1827 $  $Date: 2007-09-21 14:39:02 +0200 (pá, 21 IX 2007) $

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

if ~(is(prob,'alpha','1') && is(prob,'betha','rj,~dj') && is(prob,'gamma','Cmax'))
    error('This problem can''t be solved by Bratley.');
end


taskset.Weight = 1:size(taskset.ProcTime,2);
Tin = taskset;
taskset=sort(taskset,'ReleaseTime','ascend');
ReleaseTime=get(taskset,'ReleaseTime');
Deadline=get(taskset,'Deadline');
ProcTime=get(taskset,'ProcTime');
if sum((ProcTime+ReleaseTime)>Deadline)>0
    display('No solution for this problem');
    TS={};
else
    ret=0;
    opt=0;
    absolute=1;
    Cmax=max(Deadline);
    save_T=taskset;
    count=size(ProcTime,2);
    tasks=(1:count);
    A=zeros(count);
    solved=0;
    i=0;
    while i<=count-1
        if ~ret
            i=i+1;
        end
        ret=0;
        elapsed_time=ProcTime(i)+ReleaseTime(i);
        scheduled=i;
        if i==1
            A(1,1:end-1)=tasks(2:end);
        elseif i==count
            A(1,1:end-1)=tasks(1:end-1);
        else
            A(1,1:end-1)=[tasks(1:i-1) tasks(i+1:end)];
        end
        j=1;
        while size(scheduled,2)<count
            while size(scheduled,2)<count
                child=A(j,:);
                child=child(child>0);
                RT=ReleaseTime(child);
                PT=ProcTime(child);
                DL=Deadline(child);
                if sum((PT+max(RT,elapsed_time))>DL)>0 || (elapsed_time+sum(PT)>=Cmax && solved)
                    break;
                else
                    j=j+1;
                    scheduled=[scheduled,child(1)];
                    child=tasks(~ismember(tasks,scheduled));
                    A(j,1:size(child,2))=child;
                    elapsed_time=max(elapsed_time,ReleaseTime(scheduled(end)))...
                        +ProcTime(scheduled(end));
                    if elapsed_time<=min(ReleaseTime(child))
                        opt=1;
                        break;
                    end
                end
            end
            if opt
                break;
            end
            if (j>1)&&(size(scheduled,2)<count)
                while(sum(A(j,:)>0)<2)
                    if sum(A(1,:)>0)<2
                        break;
                    end
                    j=j-1;
                    scheduled=scheduled(1:end-1);
                end
                if sum(A(1,:)>0)<2
                    break;
                end
                A(j,1:end)=[A(j,2:end) 0];
                elapsed_time=0;
                for h=1:size(scheduled,2)
                    elapsed_time=max(ReleaseTime(scheduled(h)),elapsed_time)...
                        +ProcTime(scheduled(h));
                end
            else
                break;
            end
        end
        if size(scheduled,2)==count && (elapsed_time<Cmax || ~solved)
            ret=1;
            solved=1;
            taskset=save_T(scheduled);
            Cmax=elapsed_time;
            Release=get(taskset,'ReleaseTime');
            Proc=get(taskset,'ProcTime');
            s(1)=Release(1);
            for k=1:count-1
                s(k+1)=max(Release(k+1),s(k)+Proc(k));
            end
            for k=0:count-1
                if Release(count-k)==s(count-k)
                    if sum(Release(count-k+1:end)<Release(count-k))>0
                        absolute=0;
                    end
                    break;
                end
            end
            if absolute
                break;
            end
            absolute=1;
        end
        if opt
            a=A(j,:);
            rest=save_T(a(a>0));
            taskset=[save_T(scheduled),bratley(rest,prob)];
            if(size(taskset)==count)
                Release=get(taskset,'ReleaseTime');
                Proc=get(taskset,'ProcTime');
                s(1)=Release(1);
                for k=1:count-1
                    s(k+1)=max(Release(k+1),s(k)+Proc(k));
                end
                for k=1:count-1
                    if Release(count-k)==s(count-k)
                        if sum(Release(k+1:end)<Release(k))>0
                            absolute=0;
                        end
                        break;
                    end
                end
                solved=1;
                if absolute
                    break;
                end
                absolute=1;
            end
            opt=0;
            break;
        end
    end
    if ~solved
        TS={};
        display('No solution for this problem');
    else
        description = 'Bratley''s algorithm';
        ProcTime=get(Tin,'ProcTime');
        ord = ones(1,count);
        for i=1:count
            ord(i) = Tin.Weight(taskset.Weight == i);
        end
        add_schedule(Tin,description,s(ord),ProcTime);
        Tin.Weight = ones(1,count);
        TS=Tin;
    end
end

%end of file
