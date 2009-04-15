%% K-Fold cross validation for svm, creates 
 function [prfmce] = k_fold_cv(data,labels,N,C)
 %% Assuming half positive and half negative
 
 nobs = length(labels);
 nstart = floor(nobs/2);
 ngroups = floor(nobs/N)/2;
 rest = mod(nobs,N); %%if rest != 0 we can't continue 
 prfmce = zeros(1,N);

 
 for i = 1:N
        %data
        test_data  = data((i-1)*ngroups+1:i*ngroups,:);
        test_data  = [test_data; data(nstart+((i-1)*(ngroups)):nstart + (i*ngroups)-1,:)];
        %labels
        test_labels  = labels((i-1)*ngroups+1:(i*ngroups),:);
        test_labels  = [test_labels; labels(nstart+((i-1)*ngroups):nstart + i*ngroups-1,:)];
              
        train_data = [];
        train_labels = [];        
        for j = 1:N %% builds the training sets
            if(j ~= i)
                train_data  = [train_data; data((j-1)*ngroups+1:j*ngroups,:)];
                train_data  =  [train_data; data(nstart+((j-1)*ngroups):nstart + j*ngroups-1,:)];
                train_labels  = [train_labels; labels((j-1)*ngroups+1:j*ngroups,:)];
                train_labels  =  [train_labels; labels(nstart+(j-1)*ngroups:nstart + j*ngroups-1,:)];
            end
        end
      length(test_labels)
     
    [w0,b0,nsv,ALPHAS,svindex,E,East] = solve_svm_qp_t(train_data,train_labels,0,0,C,0,0,0);
    prfmce(i) = svm_test(w0,b0,test_data,test_labels);
      train_data = [];
      train_labels = [];
     
 end
