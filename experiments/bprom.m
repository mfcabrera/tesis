%%%% bprom, find the mean b of the SVM Solution
%%%% recomended by Simon Haykin
function bp=bprom(w0,x,svindex)
bp = mean(ones(length(svindex),1)' - w0*x(svindex,:)')

