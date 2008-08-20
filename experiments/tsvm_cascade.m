%% TSVM
% solves the transductive svm 
% input:
% training examples:
% test examples (no labeled)
% C and C* parameters from OP(2)
% num+: number of test examples to be assigned to class '+' (half)
% output:
% predicted labelss of the test examples
function [predicted_labels] = tsvm(x,d,xnl,C,Cast)  

%% Solve the liner inductive case for the trainining case
[w0,b0,nsv,ALPHAS,svindex,E,East] = solve_svm_qp_t(x,d,0,0,C,0,0);


%% Classify the test valyues using <w,b>. The num+ test example with the
% highest value of w*x+b are assigned to the class + and the remaining
% samples are assigned to class -

l = discriminant_ns(w0,b0,xnl);


ntest = length(xnl(1:end,1));

% num_plus = half half of the examples will be

num_plus = ceil(ntest/2);
[junk,idxs] = sort(l,'descend');

poslidx = idxs(1:num_plus);
neglidx = idxs(num_plus+1:end);
length(poslidx);
length(neglidx);


yast = zeros(1,ntest)';
yast(poslidx) = 1;
yast(neglidx) = -1;
l(poslidx);

CaP = 10e-5; %% some small numbers
CaN = 10e-5;

%% Main looop
while ((CaN < Cast) || (CaP < Cast)) %loop 1
  
  [w1,b1,nsv,ALPHAS,svindex,E,East,outflag] = solve_svm_qp_t(x,d,xnl,yast,C,CaP,CaN);
  
  in = 1;
  while(in > 0)
    ntest
      for(m = 1:ntest)
        for(i = 1:ntest)
               if(yast(m)*yast(i) < 0) && (East(i) > eps) && ( (East(m) + East(i)) > 2)
                   %INSIDE=666
                   yast(m) = -yast(m); %% take a positive and negative test
                   yast(i) = -yast(i); %% switch their labels and retrain
                   [w1,b1,nsv,ALPHAS,svindex,E,East,outflag] = solve_svm_qp_t(x,d,xnl,yast,C,CaP,CaN); 
                   if(outflag == 0)
                         % can be solved with this values of C
                         % so we augment them.
                         CaN = min(CaN*2,Cast);
                         CaP = min(CaP*2,Cast); 
                   end
                   in = in + 1;
               end    
               
        end
      end
      in = in - 1;
  end 
  CaN = min(CaN*2,Cast);
  CaP = min(CaP*2,Cast) ; 
end



predicted_labels = yast;









