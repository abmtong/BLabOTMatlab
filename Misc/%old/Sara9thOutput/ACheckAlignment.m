function out = ACheckAlignment(traces,fitRange)
%Fits the first fitRange (default 300) points of data in traces to @pwProtocol, a piecewise fnc that is first constant (at out(1)) and then linear (with slope -out(2)). The transition point is out(3) points in. Plots the input data and the fits.

if nargin < 2
    fitRange = 300;
end

sz = size(traces);
out = zeros(3,sz(1));
G = [3, .0001, 100]; %really doesnt matter how good these are
figure;
hold on;
for i = 1:length(out)
    out(:,i) = lsqcurvefit(@pwProtocol, G, 1:sz(2),traces(i,:));
    plot(pwProtocol(out(:,i),1:fitRange));
end
plot(traces');
end

