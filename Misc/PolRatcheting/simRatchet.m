function [trperfect, trexp] = simRatchet(t1, t2)

if nargin < 1
    t1 = ceil(1e4/90);
end

if nargin < 2
    t2 = ceil(1e4/680);
end

noi = 0; %Just adds a minimum noise level to the trace

%Default t1/t2 is from [paper] where they estimate the ratcheting rate, at 10kHz

%Trace with t1 and t2 avg pts per side

%trperfect = uniform dist.
%trexp = 1exp dist.

nst = 1e5;
trperfect = [repmat( {ones(1,t1)} , [1 nst]); repmat( {zeros(1,t2)}, [1 nst]) ];
trperfect = [trperfect{:}];

len1 = ceil( exprnd(t1, 1, nst) );
len2 = ceil( exprnd(t2, 1, nst) );
trexp = [ arrayfun(@(x) ones(1,x), len1, 'Un',0); arrayfun(@(x) zeros(1,x), len2, 'Un',0) ];
trexp = [trexp{:}];

%Okay, looks like the perfect [with no noise] spikes at (1/t1+1/t2)^-1 and multiples
%The 1exp looks like C/(f3db^2 + f^2) where for default, f3db ~122Hz (how to derive this #?)
% Freq probably still based on an 'avg' freq, but it's now of a sum of two 1exps

figure
Calibrate(trperfect + randn(size(trperfect))*noi, struct('Fs', 1e4, 'lortype', 1, 'color', [1 0 0]))
hold on
Calibrate(trexp + randn(size(trexp))*noi, struct('Fs', 1e4, 'lortype', 1, 'color', [0 0 1]))