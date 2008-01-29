% Solve SVM
% Altough specialized for Linear TSVM with the right parameters
% also solves linear SVM
function [w0,b0,nsv,ALPHAS,svindex,E,East,exitflag,H] = solve_svm_qp_t(x,d,xnl,dnl,C,Cp,Cm,X0) 

nnorm = length(d)
nnl = length(dnl);
nplus = length(find(dnl > 0));
nminus = length(find(dnl < 0));
tdctive  = false; %% whether 


%% Dummy values
%nnorm
%nplus+nminus
E = zeros(1,nnorm);
le =  length(E)
East = zeros(1,nnl);
%%b0 is the offset
%%b is the matrix b in


%%  Formula A*x = b.
%   For now normal Transductive



if(nplus > 0 && nminus > 0) 
    tdctive  = true;  
end
    
%Transductive???|
if(tdctive) 
    x = [x;xnl]; %x for training
    d = [d;dnl]; %d for training   
else
    x = x;
    d= d;
end

Y = diag(d);  %% di (labels)
n = length(d) % number of training data
H = Y*(x*x')*Y; %% Linear Kernel 
f = -1*ones(nnorm,1)';

if(tdctive) 
    %f = -1*ones(n+nminus+nplus,1)';
    A = -diag(ones(nnorm+nminus+nplus,1));
    A = [A;-A];
    f = [f -1*ones(nplus,1)'];
    f = [f -1*ones(nminus,1)'];
    b = zeros(nnorm+nminus+nplus,1);
    b = [b;C.*ones(nnorm,1);Cp.*ones(nplus,1); Cm.*ones(nminus,1) ];
    %A = [A;diag(ones(nplus,1))];
else
    
    A = -diag(ones(nnorm,1));
    A = [A;-A]; %Error bound
    b = zeros(nnorm,1);
    b = [b;C.*ones(nnorm,1)];
end

% Formula Aeq*x = beq.
Aeq = [d'];
beq = [0];

faval = 0;
exitflag =0;

%% Fetch the support vector and calculate w0 and b0 and the error vector

[ALPHAS,fval,exitflag]=quadprog(H,f,A,b,Aeq,beq,-inf,inf,X0); %% TODO: More info from QP Solver
%W
w0= (diag(ALPHAS)*d(:,1))'*x;
svindex = find(ALPHAS > eps);
if(numel(svindex) > 0)
    nsv = length(find(ALPHAS > eps));
    b0 = 1 - w0*x(svindex(1),:)' % Calculted with any svm
else
    b0 = 0;
    nsv = 0;
end
   

%% calculate the error for all both E and Easkt
for i = 1:nnorm
 %    i = i
    if(ALPHAS(i) <= eps)
        E(i) = 0;
       
    else
        
      e = 1 - d(i)*(w0*x(i,:)' + b0);
      

       
    E(i) = e;
    end
    
end
if(tdctive) 
   for i = (nnorm+1):(nplus+nminus)
    if(ALPHAS(i) <= eps)
        East(i-nnorm) = 0;
    else
%       length(xt(i,:)')
%      length(dt(i,:)')
%      length(w0)
       e = 1 - d(i)*(w0*x(i,:)' + b0) ;
       
       if(e < 0) % never happens, only happens when ALPHA(i) == 0
           e = 0;   % here just for checkin   
       end
     East(i-nnorm) = e; 
    end    
   end 
end
aja=1
length(East)
length(E)


