%% Test the implementation of solve_svm_qp_t
%loading the data



%% Test 1: Simple Linear SVM Solving
d = csm_train_lab; %% train labels
x = csm_train_vec; %% train vectors
testd = csm_test_lab; %% train labels
testx = csm_test_vec; %% train labels

C = 10;


[w0,b0,nsv] = solve_svm_qp_t(x,d,0,0,C,0,0);

nsv;
clp = svm_test(w0,b0,testx,testd)


%% Test 2: Simple Linear Transductive 
% let's split the data into unlabeled and labeled examples
lx = csm_train_vec(1:10,:);
lx = [lx;csm_train_vec(101:110,:)];
ld  = csm_train_lab(1:10,:);
ld = [ld;csm_train_lab(101:110,:)];

ulx = csm_test_vec(1:50,:);
ulx = [ulx;csm_test_vec(101:150,:)];
uld  = csm_test_lab(1:50,:);
uld = [uld;csm_test_lab(101:150,:)];

C  = 8;
Cp = 10;
Cm = 10;
 

[w0,b0,nsv] = solve_svm_qp_t(lx,ld,0,0,10,0,0);
%nsv
clp = svm_test(w0,b0,[csm_test_vec(51:100,:);csm_test_vec(151:200,:)],[csm_test_lab(51:100,:);csm_test_lab(151:200,:)])

%% K-FOLD Test for differents values of C
a = 7;
b = 15;
meanpfcs = zeros(1,b-a);
 for i = a:b
    meanpfcs(i-a+1)= mean(k_fold_cv([csm_train_vec;csm_test_vec],[csm_train_lab;csm_test_lab],5,i));
 end
   
meanpfcs 