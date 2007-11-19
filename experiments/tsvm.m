%% TSVM
% solves the transductive svm 
% input:
% training examples:
% test examples (no labeled)
% C and C* parameters from OP(2)
% num+: number of test examples to be assigned to class '+'
% output:
% predicted labelss of the test examples
function [predicted_labels] = tsvm(x,d,xnl,C,Cast) 

%% Solve the liner inductive case for the trainining case
[w0,b0,nsv,ALPHAS,svindex,E,East] = solve_svm_qp_t(x,d,0,0,C,0);








