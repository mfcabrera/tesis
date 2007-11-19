function r=recall(ycal,yexp)
    posidx =  find(yexp > 0);
    cat = ycal(posidx);
    ncor = length(find(cat > 0));         
    n = length(ycal)/2;
    r = ncor/n;
end
