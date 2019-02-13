function [fc,D] = FitLorentzian(f,P)
%Estimates fc, D to use as guesses for optimization
%from tweezercalib2.1, modified

f2 = f.^2;
    function out = s(i,j)
        out = sum(f2.^i.*P.^j);
    end
a = s(0,1) * s(2,2) - s(1,1) * s(1,2);
b = s(1,1) * s(0,2) - s(0,1) * s(1,2);
d = s(0,2) * s(2,2) - s(1,2)^2;

fc  = sqrt(a/b);
D   = 2*pi.^2*d/b;
end