%% File for testing the transductive setting

%load('csm_train_vec.data');
%load('csm_train_lab.data');
%load('csm_test_vec.data');
%load('csm_test_lab.data');

%load('ath_vs_cg_test_vec.data');
%ath_vs_cg_test_vec_sp = sparse(ath_vs_cg_test_vec);
%clear ath_vs_cg_test_vec;
%load('ath_vs_cg_test_lab.data');

%load('ath_vs_cg_train_vec.data');
%ath_vs_cg_train_vec_sp = sparse(ath_vs_cg_train_vec);
%clear ath_vs_cg_train_vec;
%load('ath_vs_cg_train_lab.data');




%lx = csm_train_vec;
%ld = csm_train_lab;

%lx = [lx;csm_train_vec(101:110,:)];
%lx  = csm_train_lab(1:10,:);
%ld = [ld;csm_train_lab(101:110,:)];

%lx = csm_train_vec(1:50,:);
%lx = [lx;csm_train_vec(101:150,:)];
%ld  = csm_train_lab(1:50,:);
%ld = [ld;csm_train_lab(101:150,:)];


%ulx = ath_vs_cg_test_vec;
%ulx = [ulx;csm_test_vec(101:199,:)];
%uld  = ath_vs_cg_test_lab;
%uld = [uld;csm_test_lab(101:199,:)];


%uld = csm_test_lab;

d = ath_vs_cg_train_lab; %[ath_vs_cg_train_lab(1:248,:);ath_vs_cg_train_lab(249:496,:)]; %% train labels
x = ath_vs_cg_train_vec_sp;%[ath_vs_cg_train_vec(1:248,:);ath_vs_cg_train_vec(249:496,:)]; %% train vectors
testd = ath_vs_cg_test_lab; %% train data
ulx = ath_vs_cg_test_vec_sp;
%inductive
tic;
[w0,b0,nsv] = solve_svm_qp_t(x,d,0,0,9,0,0);
time_inductive = toc
labels_i = svm_classify(w0,b0,ulx);

%transductive
tic;
labels_t = tsvm(x,d,ulx,10,10);
time_trans = toc;

%transductive parallell
tic;
labels_tp = tsvm_parallel(x,d,ulx,10,10);
time_trans_p = toc;

%% Results Inductive
ri = recall(labels_i,testd)
pi = precision(labels_i,testd)
fi = (2*ri*pi)/(ri+pi)


%% Results transductive
%rt = recall(labels_t,testd)
%pt = precision(labels_t,testd)
%ft = (2*rt*pt)/(rt+pt)

%% Results transductive_paralell
rtp = recall(labels_tp,testd)
ptp = precision(labels_tp,testd)
ftp = (2*rtp*ptp)/(rtp+ptp)



