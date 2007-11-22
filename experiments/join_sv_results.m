function [H,f,A,b,Aeq,beq,Xo] = join_sv_results(H1,H2,ALPHAS1,ALPHAS2,d1,d2,E1,E2,East1,East2,nplusp,nminusp,C,Cp,Cm,ltrain,ltest)
ltotal = ltest + ltrain;
H12 = H1*H2;
H21 = H2*H1;
H = [H1 H12;H21 H2];
En = [E1';East1';E2';East2']; % Initial error
length(En);
Xo = -1/2*[ALPHAS1;ALPHAS2]'*H*[ALPHAS1;ALPHAS2] + En'*[ALPHAS1;ALPHAS2];

% CREATE THE PROBLEM FORMULATIOn
% CARING ABOUT THE C,Cp,Cm Values
A = -diag(ones(ltotal,1));
A = [A;-A];
f = -1*ones(ltota,1)';
b = zeros(ltotal,1);
b = [b;C.*ones(ltrain2,1);Cp.*ones(nplusp,1); Cm.*ones(nminusp,1);Cp.*ones(nplusp,1); Cm.*ones(nminusp,1) ];
Aeq = [d1,d2]';
beq = [0];
