%% 
function clp=svm_test(w,b,data,dje)
 djr = discriminant(w,b,data)';
 temp = abs(dje+djr);
 n = length(dje);
 clp = 1 - (length(find(temp < 2)))/n;
 











