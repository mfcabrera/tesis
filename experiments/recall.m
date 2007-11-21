function r=recall(ycal,yexp)
    %recall = TP/TP+FN
    % TP/(TP+FP)
    % TP = correctamente clasificados Positivos 
    % TN = correctamente clasificados Negativos 
    % FP = Incorrectamente clasificados Positivos
    % FN = Incorrectamente clasificados Negativos 
    posidx =  find((yexp) > 0);
    tp = length(find(ycal(posidx) > 0 ));
    
    fnidx = find(yexp > 0);
    fn = length(find(ycal(fnidx) < 0));        
    r = tp/(tp+fn);
        
end
