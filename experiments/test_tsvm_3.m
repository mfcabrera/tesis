%% File for testing the transductive setting

%load('csm_train_vec.data');
%load('csm_train_lab.data');
%load('csm_test_vec.data');
%load('csm_test_lab.data');

load('ath_vs_cg_test_vec.data');
ath_vs_cg_test_vec_sp = sparse(ath_vs_cg_test_vec);
clear ath_vs_cg_test_vec;
load('ath_vs_cg_test_lab.data');

load('ath_vs_cg_train_vec.data');
ath_vs_cg_train_vec_sp = sparse(ath_vs_cg_train_vec);
%clear ath_vs_cg_train_vec;
load('ath_vs_cg_train_lab.data');




%lx = csm_train_vec;
%ld = csm_train_lab;

%lx  = csm_train_lab(1:10,:);
%lx = [lx;csm_train_vec(101:110,:)];
%ld = [ld;csm_train_lab(101:110,:)];

lx = ath_vs_cg_train_vec_sp(1:48,:);
lx = [lx;ath_vs_cg_train_vec_sp(101:148,:)];
ld  = ath_vs_cg_train_lab(1:48,:);
ld = [ld;ath_vs_cg_train_lab(101:148,:)];


ulx = ath_vs_cg_test_vec_sp;
ulx = [ulx;ath_vs_cg_train_vec_sp(101:148,:)];
testd = ath_vs_cg_test_lab(1:148,:);
testd = [testd;ath_vs_cg_test_lab(101:148,:)];




%ulx = ath_vs_cg_test_vec;
%ulx = [ulx;csm_test_vec(101:199,:)];
%uld  = ath_vs_cg_test_lab;
%uld = [uld;csm_test_lab(101:199,:)];


%uld = csm_test_lab;

%d = ath_vs_cg_train_lab; %[ath_vs_cg_train_lab(1:248,:);ath_vs_cg_train_lab(249:496,:)]; %% train labels
%x = ath_vs_cg_train_vec_sp;%[ath_vs_cg_train_vec(1:248,:);ath_vs_cg_train_vec(249:496,:)]; %% train vectors
%testd = ath_vs_cg_test_lab; %% train data
%ulx = ath_vs_cg_test_vec_sp;
%inductive
[w0,b0,nsv] = solve_svm_qp_t(lx,ld,0,0,10,0,0,0);
labels_i = svm_classify(w0,b0,ulx);

%transductive
labels_t = tsvm(lx,ld,ulx,10,10);

%transductive parallell
%labels_tp = tsvm_parallel(lx,ld,ulx,10,10);

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



