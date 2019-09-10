function hd = hamming(t,t2,m, m2)
%HAMMING calculates hamming distance between two templates
% t, t2 are the two templates and m, m2 are their respective masks
% Note that in the mask 1 indicates the bit is NOT useful.
hd = sum(sum((xor(t, t2) & ~m & ~m2)))/sum(sum(~m & ~m2));
end

