function out = calcMesoDist(inme)
%Input: Output of calcMesoE
% Get the a-b-c distribution for each site, plot as lines

strs = reshape([inme.meso], length(inme(1).meso), [])';
ps = [inme.P];
ps = ps(:);

% len = size(strs, 2);
% out = zeros(len, 3);

out = arrayfun(@(x) sum(bsxfun(@times, strs == x, ps), 1)', 'abc', 'Un', 0);
out = [out{:}];

