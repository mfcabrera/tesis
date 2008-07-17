%% Transductive Solver
%%
%%

load('datasets.dat');
load('labels.dat');
Y = diag(labels)  %% di (labels)
n = length(labels) % number of training data
H = Y*(datasets*datasets')*Y; %% Linear Kernel 
f = -1*ones(length(Y),1)';
A = -diag(ones(length(Y),1));
%%A = [A;labels'];
b = zeros(length(labels),1);
%Aeq*x = beq.
Aeq = [labels'];
beq = [0];


X=QUADPROG(H,f,A,b,Aeq,beq)

%para buscar los soporte de vectors
% find(X > eps)











