function params = GenerateParams( dwellTime, burstTime, length)

%10bp in 0.1s = 100bp/s during burst

if(nargin < 3)
    length = 100;
end

if(nargin < 2)
    burstTime = 0.1;
end

if(nargin < 1)
    dwellTime = 1;
end

l(1:2:2*length) = dwellTime;
l(2:2:2*length) = burstTime;
m(1:2:2*length) = 0;
m(2:2:2*length) = -10/burstTime;

lnew = [0 l]';
mnew = [0 m]';

params = [lnew mnew];

end

