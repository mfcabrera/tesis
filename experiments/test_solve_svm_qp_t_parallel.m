%% File for testing the transductive setting

load('csm_train_vec.data');
load('csm_train_lab.data');
load('csm_test_vec.data');
load('csm_test_lab.data'); 

%lx = csm_train_vec;
%ld = csm_train_lab;

%lx = [lx;csm_train_vec(101:110,:)];
%lx  = csm_train_lab(1:10,:);
%ld = [ld;csm_train_lab(101:110,:)];

lx = csm_train_vec; %(1:,:);
%lx = [lx;csm_train_vec(101:110,:)];
ld  = csm_train_lab;%(1:10,:);
%ld = [ld;csm_train_lab(101:110,:)];


ulx = csm_test_vec;
%ulx = [ulx;csm_test_vec(101:199,:)];
uld  = csm_test_lab;
%uld = [uld;csm_test_lab(101:199,:)];

%ulx = csm_test_vec;
%uld = csm_test_lab;

%d = csm_train_lab; %% train labels
%x = csm_train_vec; %% train vectors
%testd = csm_test_lab; %% train data

%inductive
%[w0,b0,nsv] = solve_svm_qp_t(lx,ld,0,0,10,0,0);
%labels_i = svm_classify(w0,b0,ulx);

%transductive 
%tic;
%w0  = solve_svm_qp_t(lx,ld,ulx,uld,10,5,5);
%t = toc;


[w0,b0,nsv,ALPHAS,svindex,E,East,exitflag,times]  = solve_svm_qp_t_parallel(lx,ld,ulx,uld,10,5,5);


%% Results Inductive
%ri = recall(labels_i,testd)
%pi = precision(labels_i,testd)
%fi = (2*ri*pi)/(ri+pi)


%% Results transductive
%rt = recall(labels_t,testd)
%pt = precision(labels_t,testd)
%ft = (2*rt*pt)/(rt+pt)


