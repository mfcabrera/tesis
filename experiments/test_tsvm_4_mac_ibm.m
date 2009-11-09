%% File for testing the transductive setting

%load('csm_train_vec.data');
%load('csm_train_lab.data');
%load('csm_test_vec.data');
%load('csm_test_lab.data');

  load('machw_vs_ibmhw_test_vec.data');
  machw_vs_ibmhw_test_vec_sp = sparse(machw_vs_ibmhw_test_vec);
  clear machw_vs_ibmhw_test_vec;
  load('machw_vs_ibmhw_test_lab.data');
  
  load('machw_vs_ibmhw_train_vec.data');
  machw_vs_ibmhw_train_vec_sp= sparse(machw_vs_ibmhw_train_vec);
  clear machw_vs_ibmhw_train_vec;
  load('machw_vs_ibmhw_train_lab.data');
 



%lx = csm_train_vec;
%ld = csm_train_lab;

%lx  = csm_train_lab(1:10,:);
%lx = [lx;csm_train_vec(101:110,:)];
%ld = [ld;csm_train_lab(101:110,:)];

lx = machw_vs_ibmhw_train_vec_sp(1:48,:);
lx = [lx;machw_vs_ibmhw_train_vec_sp(201:248,:)];
ld  = machw_vs_ibmhw_train_lab(1:48,:);
ld = [ld;machw_vs_ibmhw_train_lab(201:248,:)];

%400 => 396
%400 1196
%==========================================UNlABELED=================

ulx = machw_vs_ibmhw_test_vec_sp(1:800,:);
ulx = [ulx;machw_vs_ibmhw_test_vec_sp(801:1600,:)];
testd = machw_vs_ibmhw_test_lab(1:800,:);
testd = [testd;machw_vs_ibmhw_test_lab(801:1600,:)];

C=9;


%inductive
%tic;
%   st = cputime;
%   [w0,b0,nsv] = solve_svm_qp_t(lx,ld,0,0,C,0,0,0);
%   tti = (cputime - st)/60;
%   fprintf('Execution time  SVC: %4.4f minutes\n',(cputime - st)/60);
%   labels_i = svm_classify(w0,b0,ulx);
%  
 
% %transductive
%   st = cputime;
%  labels_t = tsvm(lx,ld,ulx,C,C);
%   ttd  = (cputime - st)/60;
%   fprintf('Execution time TSVC: %4.4f minutes\n',(cputime - st)/60);

%transductive parallell
     st = cputime;
    labels_tp = tsvm_parallel(lx,ld,ulx,C,C);
    fprintf('Execution time Parallel TSVC: %4.2f minutes\n',(cputime - st)/60);
    et = cputime - st;
    tptd  = (cputime - st)/60;
 
% % 
% %% Results Inductive
%  ri = recall(labels_i,testd)
%  pi = precision(labels_i,testd)
%  fi = (2*ri*pi)/(ri+pi)
% % % 
% 
% %% Results transductive
% % 
% rt = recall(labels_t,testd)
% pt = precision(labels_t,testd)
% ft = (2*rt*pt)/(rt+pt)

% %% Results transductive_paralell

    rtp = recall(labels_tp,testd)
    ptp = precision(labels_tp,testd)
    ftp = (2*rtp*ptp)/(rtp+ptp)
% 
% x = toc;
%  
% fprintf('Execution time SVC: %4.4f minutes\n',tti);
% fprintf('Execution time TSVC: %4.4f minutes\n',ttd);
fprintf('Execution time Parallel TSVC: %4.4f minutes\n',tptd);

blah



