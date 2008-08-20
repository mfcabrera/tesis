 %% Transductive Solver
%%
%%

load('data-train.data');
load('label-train.dat');
Y = diag(label-train)  %% di (labels)
n = length(label-train) % number of training data
H = Y*(data-train*data-train')*Y; %% Linear Kernel 
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











