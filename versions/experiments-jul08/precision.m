function p=precision(ycal,yexp)
 %% TP/(TP+FP)
% TP = correctamente clasificados Positivos 
% TN = correctamente clasificados Negativos 
% FP = Incorrectamente clasificados Positivos
% FN = Incorrectamente clasificados Negativos    
 posidx =  find((yexp) > 0);
 tp = length(find(ycal(posidx) > 0 ));
 
 fpidx = find(yexp < 0);
 fp = length(find(ycal(fpidx) > 0)) ;          
 p = tp/(tp+fp);
        
end