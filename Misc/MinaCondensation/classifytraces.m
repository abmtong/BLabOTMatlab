function out = classifytraces(infrc, inext)
%First cutoff is frc +- 10pN, above 10, out == 0
% For those below, check slope: decreasing, == 1; else == 2
frcs = cellfun(@mean, infrc);
out = 2*ones(1,length(frcs));
out(frcs > 10) = 0;
slps = cellfun(@(x) (x(end) - x(1))/length(x), inext);
out(frcs <= 10 & slps < 0) = 1;