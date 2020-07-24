%Load sample data
load laboh
%The data is stored in 'a'

%Run pause detection on eighth trace using SGP parameters (n.k) = {1, 301}
vizSGF(a, {1 301}, 1)
%After you run this, click on the velocity distribution to set a velocity cutoff
