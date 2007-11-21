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
nplusp = nplus/4;
nminusp = nminus/4;

plus_idx = find(dnl > 0);
minus_idx = find(dnl < 0);

xnlplus = xnl(plus_idx);
xnlminus = xnl(minus_idx);

dnlplus = dnl(plus_idx);
dnlminus = dnl(minus_idx);

% Us
U1v =  [xnlplus(1:nplusp,:);xnlminus(1:nminusp,:)]; 
U1d =  [dnlplus(1:nplusp,:);dnlminus(1:nminusp,:)] ;
U2v =  [xnlplus(nplusp+1:nplus*2,:);xnlminus(nminusp+1:nminusp*2,:)]; 
U2d =  [dnlplus(nplusp+1:nplus*2,:);dnlminus(nminusp+1:nminusp*2,:)]; 
U3v =  [xnlplus(nplusp*2+1:nplus*3,:);xnlminus(nminusp*2+1:nminusp*3,:)]; 
U3d =  [dnlplus(nplusp*2+1:nplus*3,:);dnlminus(nminusp*2+1:nminusp*3,:)]; 
U4v =  [xnlplus(nplusp*3+1:nplus*4,:);xnlminus(nminusp*3+1:nminusp*4,:)]; 
U4d =  [dnlplus(nplusp*3+1:nplus*4,:);dnlminus(nminusp*3+1:nminusp*4,:)]; 

%% SPLIT LABELED DATA
psize = nnorm/nmachines;
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

%% JOIN THE LABELED AND THE UNLABELED DATA

%% NOW Solve the first SVMs

 [w1,b1,nsv1,ALPHAS1,svindex1,E1,East1,exitflag1] = solve_svm_qp_t(x,d,xnl,dnl,C,Cp,Cm)



