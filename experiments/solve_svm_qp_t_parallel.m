%%
% Solve SVM
% Altough specialized for Linear TSVM with the right parameters
% also solves linear SVM
function [w0,b0,nsv,ALPHAS1234orig,svindex,E,East,exitflag7,times] = solve_svm_qp_t_parallel(x,d,xnl,dnl,C,Cp,Cm) 

nnorm = length(d)
nplus = length(find(dnl > 0));
nminus = length(find(dnl < 0));
ntotal = nnorm + nplus + nminus
tdctive  = false; %% whether 
times = 0


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
nminusp = nminus/4

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
%length(U3d)
%length(U2d)
%PARTE PAR
dummyX = zeros(1,length(L1d)+length(U1d));
[W,B,NSV,AL,SVINDEX,EV,EASTV,EXITF,HV] = dfeval(@solve_svm_qp_t,{L1v,L2v,L3v,L4v},{L1d,L2d,L3d,L4d},{U1v,U2v,U3v,U4v},{U1d,U2d,U3d,U4d},{C,C,C,C},{Cp,Cp,Cp,Cp},{Cm,Cm,Cm,Cm},{dummyX,dummyX,dummyX,dummyX},'Configuration', 'local');
%[w1,b1,nsv1,ALPHAS1,svindex1,E1,East1,exitflag1,H1] = solve_svm_qp_t(L1v,L1d,U1v,U1d,C,Cp,Cm,dummyX);
%[w4,b4,nsv4,ALPHAS4,svindex4,E4,East4,exitflag4,H4] =  solve_svm_qp_t(L4v,L4d,U4v,U4d,C,Cp,Cm,dummyX);
%[w2,b2,nsv2,ALPHAS2,svindex2,E2,East2,exitflag2,H2] = solve_svm_qp_t(L2v,L2d,U2v,U2d,C,Cp,Cm,dummyX);
%[w3,b3,nsv3,ALPHAS3,svindex3,E3,East3,exitflag3,H3] =  solve_svm_qp_t(L3v,L3d,U3v,U3d,C,Cp,Cm,dummyX);

%% Rebuild  the Q matrix for the next layer

%Second Level layer


w1 = W{1};
w2 = W{2};
w2 = W{3};
w2 = W{4};

b1 = B{1};
b3 = B{2};
b2 = B{2};
b2 = B{4};

nsv1 =  NSV{1};
nsv2 =  NSV{2};
nsv3 =  NSV{3};
nsv4 =  NSV{4};

ALPHAS1 = AL{1};
ALPHAS2 = AL{2};
ALPHAS3 = AL{3};
ALPHAS4 = AL{4};

svindex1 = SVINDEX{1};
svindex2 = SVINDEX{2};
svindex3 = SVINDEX{3};
svindex4 = SVINDEX{4};

E1 = EV{1};
E2 = EV{2};
E3 = EV{3};
E4 = EV{4};
%length(E1)
%length(E2)
%length(E3)
%length(E4)


East1 = EASTV{1};
East2 = EASTV{2};
East3 = EASTV{3};
East4 = EASTV{4};

exitflag1 = EXITF{1};
exitflag2 = EXITF{2};
exitflag3 = EXITF{3};
exitflag4 = EXITF{4};

H1 = HV{1};
H2 = HV{2};
H3 = HV{3};
H4 = HV{4};


 
 %solve_svm_qp_t(L1v,L1d,U1v,U1d,C,Cp,Cm);
% [w2,b2,nsv2,ALPHAS2,svindex2,E2,East2,exitflag2,H2] = solve_svm_qp_t(L2v,L2d,U2v,U2d,C,Cp,Cm);
% [w3,b3,nsv3,ALPHAS3,svindex3,E3,East3,exitflag3,H3] = solve_svm_qp_t(L3v,L3d,U3v,U3d,C,Cp,Cm);
% [w4,b4,nsv4,ALPHAS4,svindex4,E4,East4,exitflag4,H4] = solve_svm_qp_t(C);
% TO PARALELIZE 

ALPHAS1234orig = [ALPHAS1' ALPHAS2' ALPHAS3'  ALPHAS4'];
%ALPHAS1234orig = ALPHAS1234orig';

ltrain2 = length(L1d) + length(L2d);
ltest2 = length(U1d) + length(U2d);
ltotal2 = ltest2 + ltrain2;

%we can made a function out of this

%% Second layer
%%SV5 = SV1 + SV2
%%SV6 = SV3 + SV4
% LETS JOIN THE SV 
%l = length(H1)/2;
% CREATE THE PROBLEM FORMULATIOn

%ALPHAS = [ALPHAS1; ALPHAS2; ALPHAS3; ALPHAS4]    


[H5,f5,A5,b5,Aeq5,beq5,X5] = join_sv_results(H1,H2,ALPHAS1,ALPHAS2,[L1d;U1d],[L2d;U2d],E1,E2,East1,East2,nplusp,nminusp,C,Cp,Cm,ltrain2,ltest2);
[H6,f6,A6,b6,Aeq6,beq6,X6] = join_sv_results(H3,H4,ALPHAS3,ALPHAS3,[L3d;U3d],[L4d;U4d],E3,E4,East3,East4,nplusp,nminusp,C,Cp,Cm,ltrain2,ltest2);

%%


%% Eliminate the early non-support vectors

real_size = psize*2;

svindex1l = svindex1(find(svindex1 <= real_size));
svindex2l = svindex2(find(svindex2 <= real_size));
svindex3l = svindex3(find(svindex3 <= real_size));
svindex4l = svindex4(find(svindex4 <= real_size));

svindex1u = svindex1(find(svindex1 > real_size+1)) - real_size;
svindex2u = svindex2(find(svindex2 > real_size+1)) - real_size;
svindex3u = svindex3(find(svindex3 > real_size+1)) - real_size;
svindex4u = svindex4(find(svindex4 > real_size+1)) - real_size;


% Variable Name Format: Layer_{LayerNumber}{SV_Number}_{Labeled or Un Labeled}{Vector or D (class)}
%% Añadirle los sizes de estos locos aca
Layer21_LV = [L1v(svindex1l,:);L2v(svindex2l,:)];   
Layer21_UV = [U1v(svindex1u,:);U2v(svindex2u,:)];
Layer21_LD = [L1d(svindex1l,:);L2d(svindex2l,:)];
Layer21_UD = [U1d(svindex1u,:);U2d(svindex2u,:)];

Layer22_LV = [L3v(svindex3l,:);L3v(svindex3l,:)];
Layer22_UV = [U3v(svindex3u,:);U3v(svindex3u,:)];
Layer22_LD = [L4d(svindex4l,:);L4d(svindex4l,:)];
Layer22_UD = [U4d(svindex4u,:);U4d(svindex4u,:)];


svindex12l = [svindex1l;svindex2l+real_size]

%Layer22_IV = [L1v(svindex3);L2v(svindex4)];
%disp('Size of Layer21_LV');
%disp(length(Layer21_LV(1,:)));
%disp(length(Layer21_LD(:,1)));
%disp(length(Layer21_UV(1,:)));
%disp(length(Layer21_UD(:,1)));
%disp('X5 = ');
%disp(length(X5));

%% FIXME:  HACK:Dirty hack, we do not calculate the X0 again from the svs , we just eliminate
%   resize the original 
layer21l_size = length(Layer21_LD(:,1))
layer21u_size =  length(Layer21_UD(:,1))
layer22l_size = length(Layer22_LD(:,1))
layer22u_size =  length(Layer22_UD(:,1))

layer21size = layer21l_size + layer21u_size;
layer22size = layer22l_size +layer22u_size;

X0_21 = X5(1: layer21l_size + layer21u_size);
X0_22 = X6(1: layer22l_size + layer22u_size);


% SECOND LAYER

[W,B,NSV,AL,SVINDEX,EV,EASTV,EXITF,HV] = dfeval(@solve_svm_qp_t,{Layer21_LV,Layer22_LV},{Layer21_LD,Layer22_LD},{Layer21_UV,Layer22_UV},{Layer21_UD,Layer22_UD},{C,C},{Cp,Cp},{Cm,Cm},{dummyX,dummyX},'Configuration', 'local');

%[w5,b5,nsv5,ALPHAS5,svindex5,E5,East5,exitflag5,H5] = solve_svm_qp_t(Layer21_LV,Layer21_LD,Layer21_UV,Layer21_UD,C,Cp,Cm,X0_21);
%[w6,b6,nsv6,ALPHAS6,svindex6,E6,East6,exitflag6,H6] = solve_svm_qp_t(Layer22_LV,Layer22_LD,Layer22_UV,Layer22_UD,C,Cp,Cm,X0_22);
w5 = W{1};
w6 = W{2};

b5 = B{1};
b6 = B{2};

nsv5 =  NSV{1};
nsv6 =  NSV{2};

ALPHAS5 = AL{1};
ALPHAS6 = AL{2};

svindex5 = SVINDEX{1};
svindex6 = SVINDEX{2};

E5 = EV{1};
E6 = EV{2};

East5 = EASTV{1};
East6 = EASTV{2};

exitflag5 = EXITF{1};
exitflag6 = EXITF{2};

H5 = HV{1};
H6 = HV{2};





%% Remove one more time early support vectors
%% Solve the last Layer with the reduced vectors 
% Tengo que unir 5 y 6 en uno solo y correrlo!


ALPHAS56orig = [ALPHAS5;ALPHAS6];

svindex5l = svindex5(find(svindex5 <= layer21l_size));
svindex6l = svindex6(find(svindex6 <= layer22l_size));
disp('svindex5u and svindex5u');
svindex5u  = svindex5(find(svindex5 > layer21l_size + 1)) - layer21l_size;
svindex6u = svindex6(find(svindex6 > layer22l_size + 1))  - layer22l_size;




% Join the sets 
Layer3LV = [Layer21_LV(svindex5l,:);Layer22_LV(svindex6l,:)];
Layer3UV = [Layer21_UV(svindex5u,:);Layer22_UV(svindex6u,:)];
Layer3LD = [Layer21_LD(svindex5l,:);Layer22_LD(svindex6l,:)];
Layer3UD = [Layer21_UD(svindex5u,:);Layer22_UD(svindex6u,:)];


%% FIXME:  HACK:Dirty hack, we do not calculate the X0 again from the svs , we just eliminate
%   resize the original 
layer3l_size = length(Layer3LD(:,1));
layer3u_size =  length(Layer3UD(:,1));
X3 = [X5;X6];
X0_3= X3(1:(layer3l_size + layer3u_size));

[w7,b7,nsv7,ALPHAS7,svindex7,E7,East7,exitflag7,H7] = solve_svm_qp_t(Layer3LV,Layer3LD,Layer3UV,Layer3UD,C,Cp,Cm,X0_3);


ALPHAS56orig(:) = 0.0000;
ALPHAS56orig(svindex7) = ALPHAS7(svindex7);


svindex56 = [svindex5;svindex5+length(svindex6)];
ALPHAS1234orig(:) = 0.0000;
ALPHAS1234orig(svindex56) = ALPHAS56orig(svindex56);
length(ALPHAS1234orig);
 



%% Solve the second layer

%[AL,FVAL,EF] = dfeval(@quadprog,{H5,H6},{f5,f6},{A5,A6},{b5,b6},{Aeq5,Aeq6},{beq5,beq6},{-inf,-inf},{inf,inf},{X5,X6},'Configuration', 'local');

%ALPHAS5 = AL{1};
%ALPHAS6 = AL{2};
%exitflag5 = EF{1};
%exitflag6 = EF{2};

%[ALPHAS5,fval,exitflag5]=quadprog(H5,f5,A5,b5,Aeq5,beq5,-inf,inf,X5);
%[ALPHAS6,fval,exitflag6]=quadprog(H6,f6,A6,b6,Aeq6,beq6,-inf,inf,X6);

%% LAST LAYER

%[H7,f7,A7,b7,Aeq7,beq7,X7] = join_sv_results(H5,H6,ALPHAS5,ALPHAS6,[L1d;U1d;L2d;U2d],[L3d;U3d;L4d;U4d],[E1 E2],[E3 E4],[East1 East2],[East3 East4],nplusp*2,nminusp*2,C,Cp,Cm,ltrain2*2,ltest2*2);
%[ALPHAS,fval,exitflag]=quadprog(H7,f7,A7,b7,Aeq7,beq7,-inf,inf,X7);


xt = [x;xnl]; %x for training
dt = [d;dnl]; %d for training   
%w0 = w7;
w0= (diag(ALPHAS1234orig)*dt(:,1))'*xt;
svindex = find(ALPHAS1234orig > eps);

if(numel(svindex) > 0)
    nsv = length(svindex);
    b0 = 1 - w0*x(svindex(1),:)' % Calculted with any svm
else
    b0 = 0;
    nsv = 0;
end

for i = 1:nnorm
    if(ALPHAS1234orig(i) <= eps)
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
    if(ALPHAS1234orig(i) <= eps)
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



