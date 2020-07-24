function [out, sgn] = simtrace(noi, sm)
n=100; %total steps
if nargin < 1
    noi = 3; %sd noise
end

if nargin < 2
    sm = [];
end

%number of points for step/substeps
% dwp = 166; %time at dwell: same length as usual dwell (usual length is ~166ms)
% bup = 100; %Moffitt has subdwells ~50ms = 125 pts at 2.5kHz, but we have 60bp/s = 24st/s = 100ms

%loF: dist. is different
dwp = 200;
bup = 20;

% sts = [2.5 2.5 2.5 2];
% sts = 2.2 * ones(1,4);
sts = 2.4 * ones(1,4);

out = cell(1,n);
loc = 9000;

modi = @(x) mod(x-1, length(sts))+1;

for i = 1:n
    j = modi(i);
    if j == 1 %first step is different: use different dwell time
        out{i} = loc * ones(1,dwp);
    else
        out{i} = loc * ones(1,bup);
    end
    loc = loc - sts(j);
end
out = [out{:}];

%smooth signal
if ~isempty(sm)
    out = smooth(out, sm)';
end
sgn = out;
out = out + noi * randn(size(out));