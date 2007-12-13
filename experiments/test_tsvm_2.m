%% File for testing the transductive setting

load('csm_train_vec.data');
load('csm_train_lab.data');
load('csm_test_vec.data');
load('csm_test_lab.data');

%lx = csm_train_vec;
%ld = csm_train_lab;


lx = csm_train_vec(1:32,:);
lx = [lx;csm_train_vec(101:132,:)];
ld  = csm_train_lab(1:32,:);
ld = [ld;csm_train_lab(101:132,:)];


ulx = csm_test_vec;
%ulx = [ulx;csm_test_vec(101:199,:)];
uld  = csm_test_lab;
%uld = [uld;csm_test_lab(101:199,:)];

%ulx = csm_test_vec;
%uld = csm_test_lab;

d = csm_train_lab; %% train labels
x = csm_train_vec; %% train vectors
testd = csm_test_lab; %% train data

%inductive
%tic;
%[w0,b0,nsv] = solve_svm_qp_t(lx,ld,0,0,10,0,0);
%abels_i = svm_classify(w0,b0,ulx);
%tinducitve = toc

%transductive
tic;
labels_t = tsvm(lx,ld,ulx,10,10);
ttrans = toc

tic;
%transductive parallell
labels_tp = tsvm_parallel(lx,ld,ulx,10,10);
ttrans_p = toc

%% Results Inductive
ri = recall(labels_i,testd)
pi = precision(labels_i,testd)
fi = (2*ri*pi)/(ri+pi)


%% Results transductive
rt = recall(labels_t,testd)
pt = precision(labels_t,testd)
ft = (2*rt*pt)/(rt+pt)

%% Results transductive_paralell
%rtp = recall(labels_tp,testd)
%ptp = precision(labels_tp,testd)
%ftp = (2*rtp*ptp)/(rtp+ptp)



