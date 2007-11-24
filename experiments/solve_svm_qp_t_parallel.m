% Solve SVM
% Altough specialized for Linear TSVM with the right parameters
% also solves linear SVM
function [w0,b0,nsv,ALPHAS,svindex,E,East,exitflag] = solve_svm_qp_t_parallel(x,d,xnl,dnl,C,Cp,Cm) 

nnorm = length(d);
nplus = length(find(dnl > 0));
nminus = length(find(dnl < 0));
ntotal = nnorm + nplus + nminus;
tdctive  = false; %% whether 


%% Dummy values
E = zeros(1,nnorm);
East = zeros(1,nplus+nminus);
%%b0 is the offset
%%b is the matrix b in


%%  Formula A*x = b.
%   For now normal Transductive



if(nplus > 0 && nminus > 0) 
    tdctive  = true;  
end
    
%Transductive???|
%if(tdctive) 
%    xt = [x;xnl]; %x for training
%    dt = [d;dnl]; %d for training   
%else
%    xt = x;
%    dt = d;
%end

%% Here Begins the paralell part
% how to split the data?
%UNLABELED DATA 
%   POSITIVE/4
%   NEGATIVE/4
%   JOIN 4 PAIRS OF NEGATIVE AND POSITIVE
% LABELED DATA
%   POSITIVE/4
%   NEGATIVE/4
%   JOIN 4 PAIRS
%
% JOIN TWO DATSETS
%   L1+U4 (SD1)
%   L2+U3 (SD2)
%   L3+U2 (SD3)
%   L4+U1 (SD4)
% TRAIN WITH 4 MACHINES

%% SPLIT UNLABELED DATA
nplusp = nplus/4
nminusp = nminus/4;

plus_idx = find(dnl > eps);
minus_idx = find(dnl < eps);

xnlplus = xnl(plus_idx,:);
xnlminus = xnl(minus_idx,:);

dnlplus = dnl(plus_idx,:);
dnlminus = dnl(minus_idx,:);

% Us

U1v =  [xnlplus(1:nplusp,:);xnlminus(1:nminusp,:)]; 
U1d =  [dnlplus(1:nplusp,:);dnlminus(1:nminusp,:)] ;
U2v =  [xnlplus(nplusp+1:nplusp*2,:);xnlminus(nminusp+1:nminusp*2,:)]; 
U2d =  [dnlplus(nplusp+1:nplusp*2,:);dnlminus(nminusp+1:nminusp*2,:)]; 
U3v =  [xnlplus(nplusp*2+1:nplusp*3,:);xnlminus(nminusp*2+1:nminusp*3,:)]; 
U3d =  [dnlplus(nplusp*2+1:nplusp*3,:);dnlminus(nminusp*2+1:nminusp*3,:)]; 
U4v =  [xnlplus(nplusp*3+1:nplusp*4,:);xnlminus(nminusp*3+1:nminusp*4,:)]; 
U4d =  [dnlplus(nplusp*3+1:nplusp*4,:);dnlminus(nminusp*3+1:nminusp*4,:)]; 

%% SPLIT LABELED DATA
psize = ceil(nnorm/8)
%PART 1
L1v = [ x(1:psize,:); x(psize*7+1:psize*8,:)];
L1d = [ d(1:psize,:); d(psize*7+1:psize*8,:)];
%PART 2
L2v = [ x(psize+1:psize*2,:); x(psize*5+1:psize*6,:)];
L2d = [ d(psize+1:psize*2,:); d(psize*5+1:psize*6,:)];
%PART 3
L3v = [ x(psize*2+1:psize*3,:); x(psize*6+1:psize*7,:)];
L3d = [ d(psize*2+1:psize*3,:); d(psize*6+1:psize*7,:)];
%PART 4
L4v = [ x(psize*3+1:psize*4,:); x(psize*7+1:psize*8,:)];
L4d = [ d(psize*3+1:psize*4,:); d(psize*7+1:psize*8,:)];

%% FIRST LAYER OF SVM


%% NOW Solve the first 4 SVMs

% TO PARALELIZE 
 [w1,b1,nsv1,ALPHAS1,svindex1,E1,East1,exitflag1,H1] = solve_svm_qp_t(L1v,L1d,U1v,U1d,C,Cp,Cm);
 [w2,b2,nsv2,ALPHAS2,svindex2,E2,East2,exitflag2,H2] = solve_svm_qp_t(L1v,L1d,U1v,U1d,C,Cp,Cm);
 [w3,b3,nsv3,ALPHAS3,svindex3,E3,East3,exitflag3,H3] = solve_svm_qp_t(L1v,L1d,U1v,U1d,C,Cp,Cm);
 [w4,b4,nsv4,ALPHAS4,svindex4,E4,East4,exitflag4,H4] = solve_svm_qp_t(L1v,L1d,U1v,U1d,C,Cp,Cm);
% TO PARALELIZE 

ltrain2 = length(L1d) + length(L2d);
ltest2 = length(U1d) + length(U2d);
%ltotal2 = ltest2 + ltrain2;

%we can made a function out of this
%% Second layer
%%SV5 = SV1 + SV2
%%SV6 = SV3 + SV4
% LETS JOIN THE SV 
%l = length(H1)/2;
% CREATE THE PROBLEM FORMULATIOn
[H5,f5,A5,b5,Aeq5,beq5,X5] = join_sv_results(H1,H2,ALPHAS1,ALPHAS2,[L1d;U1d],[L2d;U2d],E1,E2,East1,East2,nplusp,nminusp,C,Cp,Cm,ltrain2,ltest2);
[H6,f6,A6,b6,Aeq6,beq6,X6] = join_sv_results(H3,H4,ALPHAS3,ALPHAS3,[L3d;U3d],[L4d;U4d],E3,E4,East3,East4,nplusp,nminusp,C,Cp,Cm,ltrain2,ltest2);

%% Solve the second layer
[ALPHAS5,fval,exitflag5]=quadprog(H5,f5,A5,b5,Aeq5,beq5,-inf,inf,X5);
[ALPHAS6,fval,exitflag6]=quadprog(H6,f6,A6,b6,Aeq6,beq6,-inf,inf,X6);

%% LAST LAYER

[H7,f7,A7,b7,Aeq7,beq7,X7] = join_sv_results(H5,H6,ALPHAS5,ALPHAS6,[L1d;U1d;L2d;U2d],[L3d;U3d;L4d;U4d],[E1 E2],[E3 E4],[East1 East2],[East3 East4],nplusp*2,nminusp*2,C,Cp,Cm,ltrain2*2,ltest2*2);

[ALPHAS,fval,exitflag]=quadprog(H7,f7,A7,b7,Aeq7,beq7,-inf,inf,X7);

xt = [x;xnl]; %x for training
dt = [d;dnl]; %d for training   
w0= (diag(ALPHAS)*dt(:,1))'*xt;
svindex = find(ALPHAS > eps);
nsv = length(find(ALPHAS > eps));
b0 = 1 - w0*xt(svindex(1),:)' % Calculted with any svm


for i = 1:nnorm
    if(ALPHAS(i) <= eps)
        E(i) = 0;
    else
        
      e = 1 - dt(i)*(w0*xt(i,:)' + b0);
      

       if(e < 0) % never happens, only happens when ALPHA(i) == 0
          e = 0;   % here just for checkin   
       end
    E(i) = e;
    end
end
if(tdctive) 
   for i = (nnorm+1):(nplus+nminus)
    if(ALPHAS(i) <= eps)
        E(i-nnorm) = 0;
    else
%       length(xt(i,:)')
%      length(dt(i,:)')
%      length(w0)
       e = 1 - dt(i)*(w0*xt(i,:)' + b0) ;
       
       if(e < 0) % never happens, only happens when ALPHA(i) == 0
           e = 0;   % here just for checkin   
       end
     East(i-nnorm) = e; 
    end    
   end 
end


