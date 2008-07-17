%% Transductive Solver
%%
%%

load('aa_train_vec.data');
load('aa_train_lab.data');
load('aa_test_vec.data');
load('aa_test_lab.data');

C=900
d = aa_test_lab;
x = aa_test_vec;
Y = diag(d);  %% di (labels)
n = length(d); % number of training data
H = Y*(x*x')*Y; %% Linear Kernel 
f = -1*ones(length(Y),1)';
A = -diag(ones(length(Y),1));
A = [A;ones(length(Y),1)']; %Error bound
%%A = [A;labels'];
b = zeros(length(d),1);
b = [b;C];
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
svm_test(w0,b0,aa_train_vec,aa_train_lab)










