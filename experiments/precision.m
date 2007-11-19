function p=precision(ycal,yexp)
    posidx =  find(yexp > 0);
    cat = ycal(posidx);
    ncor = length(find(cat > 0));  
    n = length(find (ycal > 0));
    p = ncor/n;
    
    
end