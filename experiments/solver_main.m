%% Transductive Solver
%%
%%

load('csm_train_vec.data');
load('csm_train_lab.data');
load('csm_test_vec.data');
load('csm_test_lab.data');

C=8
d = csm_train_lab;
x = csm_train_vec;
%d = [csm_test_lab([1:30],:);csm_test_lab([100:129],:)];
%x = [csm_test_vec([1:30],:);csm_test_vec([100:129],:)];
Y = diag(d);  %% di (labels)
n = length(d); % number of training data
H = Y*(x*x')*Y; %% Linear Kernel 
f = -1*ones(n,1)';
A = -diag(ones(n,1));
A = [A;-A]; %Error bound
b = zeros(n,1);
b = [b;C.*ones(n,1)];
%%  Formula Aeq*x = beq.
Aeq = [d'];
beq = [0];


ALPHAS=quadprog(H,f,A,b,Aeq,beq);
%%W
w0= (diag(ALPHAS)*d(:,1))'*x;
svindex = find(ALPHAS > eps);
nsv = length(find(ALPHAS > eps))
b0 = 1 - w0*x(svindex(1),:)'
%b0 = bprom(w0,x,svindex)

%para buscar los soporte de vectors
% find(X > eps)
clp = svm_test(w0,b0,csm_test_vec,csm_test_lab)










