function [G_FLOW, fmin] = mincostflow(varargin)
%MINCOSTFLOW finds the least cost flow in graph G.
%
% Synopsis
%   [G_FLOW, FMIN] = MINCOSTFLOW(G)
%   [G_FLOW, FMIN] = MINCOSTFLOW(U,C,D,N)
%
% Description
%   [G_FLOW, FMIN] = MINCOSTFLOW(G) finds the cheapest flow in graph G.
%   Prices in graph G, lower and upper bounds of flows are specified
%   in first, second and third user parameter on edges (UserParam).
%   The function returns graph G_FLOW, i.e. graph G enlarged with fourth user
%   parameter which contains amount of flow in every edge. FMIN contains
%   total cost.
%
%   [G_FLOW, FMIN] = MINCOSTFLOW(U,C,D,N) finds the same, but everything
%   without using graph, only matrixes. U is matrix of prices, C means 
%   lower bounds of flows, D upper bounds. The function returns G_FLOW,
%   matrix of minimal flows.
%
% See also GRAPH/GRAPH, ILINPROG, EDGES2MATRIXPARAM, MATRIXPARAM2EDGES.

%   Author(s): J. Jindra, P. Sucha
%   Copyright (c) 2005 CTU FEE
%   $Revision: 1896 $  $Date: 2007-10-12 08:13:54 +0200 (pá, 12 X 2007) $

na = nargin;
if (na == 1 && isa(varargin{1},'graph'))
   g = varargin{1};
   n = size(g.N,2);                       %Number of graph nodes
   adj_g = adj(g);
   
   b=[];                                  %Create vector b (Ax=b)
   for(i=1:n)
       fixFlow=g.N{i}.UserParam;
       b(i,1)=-fixFlow{1};
   end;
      
   A = -inc(g);
   
   price = [];
   cb = [];
   db = [];
   
   F = Inf*ones(size(adj_g,1),size(adj_g,2));
         
   [x,y] = find(adj_g == 1);
   
   for i = 1:length(x)
       
       edge = g.E(between(g,x(i),y(i)));
       if(length(edge)~=1)
           error('Graph with parallel edges is not supported.');
       end;
       params = edge{1}.UserParam;
       
       if(length(params) == 3)
           price = [price params{1}];
           % check input parameters
           if (params{2} > params{3}) 
               error('Lower bound is higher than upper bound!');
           end;
           cb = [cb params{2}];
           db = [db params{3}];
           F(x(i),y(i)) = -1;
       else
           error('Not enough/too many params of edges.');
       end;
   end

% only-matrix version
elseif (na == 4 && isnumeric(varargin{1}) && isnumeric(varargin{2}) && isnumeric(varargin{3}) && isnumeric(varargin{4}))
    Full_matrix = varargin{1};
    g = create_graph(Full_matrix);
    C = varargin{2};
    D = varargin{3};
    flows = varargin{4};
    
    % check input parameters
    if (length(find(C>D)) > 0)
        error('Low-bound is higher than up-bound!');
    end;
    
    n = size(g.N,2);
    b = [-1*flows zeros(1,n-2) 1*flows]';
    A = -inc(g);
    F = Inf*ones(size(adj(g),1),size(adj(g),2));

    price = [];
    cb = [];
    db = [];
    
    [x,y] = find(adj(g) == 1);
    
    for i = 1:length(x)
        price = [price Full_matrix(x(i),y(i))];
        cb = [cb C(x(i),y(i))];
        db = [db D(x(i),y(i))];
        F(x(i),y(i)) = -1;
    end;
    

else
    error('Input graph must be specified by object GRAPH or by matrices U, C and D.');
end


%%% Solution by ILP (LP) %%%
price = price';
cb = cb';
db = db';
sense = 1;    %type of optimalization: 1=minimalization, -1=maximalization
ctype=''; ctype(1:size(b,1),1)='E';
vartype=''; vartype(1:size(price,1),1) = 'I';

schoptions=schoptionsset('ilpSolver','glpk','solverVerbosity',0);
[xmin,fmin,status,extra] = ilinprog (schoptions,sense,price,A,b,ctype,cb,db,vartype);

if(status==1)
    %disp('Successful.');
	for i=1:size(F,1)
        for j=1:size(F,2)
            if (F(j,i) < 0) 
                F(j,i) = xmin(1);
                xmin = xmin(2:end);
            end;
        end;
	end;
    if (na == 1) 
        G_FLOW = matrixparam2edges(g,F,4);
    else
        G_FLOW = F;
    end;
else
    G_FLOW = [];
    fmin = [];
    %disp('Problem has not solution.');
end;

%end .. @graph/mincostflow
