%% 
function clp=test_labels(computed,expected)
 temp = abs(computed+expected);
 n = length(computed);
 clp = 1 - (length(find(temp < 2)))/n;
 











