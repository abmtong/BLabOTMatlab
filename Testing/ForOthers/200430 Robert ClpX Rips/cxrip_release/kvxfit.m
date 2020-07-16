function [out, sszs, dwts, outraw] = kvxfit(in, me, con, verbose)
%Tests the goodness of fit of KV as a signifier of SNR
%Given one step (dwell then step), cf MSE to line drawn from midpts

nstep = length(me);
qe1 = zeros(1, nstep);
qe2 = zeros(1, nstep);

for i = 2:nstep-1
    %Points is from in(i) to in(i+1)-1
    concrp = con(in(i):in(i+1)-1);
    qe1(i) = mean((concrp - me(i)) .^2);
    %Line connects 3 closest midpts
    ptx = [in(i) (in(i)+in(i+1))/2 in(i+1)];
    pty = (me(i-1:i+1) + me(i))/2;
    pf = polyfit(ptx, pty, 1);
    lnfit = polyval(pf, in(i):in(i+1)-1);
    ctil = concrp - lnfit;
%     qe2(i) = mean((ctil - mean(ctil)).^2);
    qe2(i) = mean((ctil).^2);
end
outraw = {qe1 qe2};
out = qe1<qe2;

%This is a kind of dwell-validating algo, so good steps = dwell before and after are good
sszs = diff(me);
sszs = sszs(out(1:end-1) & out(2:end));
dwts = diff(in);
dwts = dwts(out);

if nargin > 3 && verbose
    %Plot trace and fit, coloring by if step is good or not
    figure Name KVxfit
    plot(con), hold on
    [xx,yy] = ind2lin(in,me);
    cc = repmat(out, [2 1]);
    cc = cc(:)';
    cc = double(cc);
    surface([xx;xx],[yy;yy],zeros(2,length(xx)),[cc;cc], 'Edgecol', 'interp', 'LineWidth',1)
    colormap([1 0 0; 0 1 0]);
    for i = 1:nstep-1
        text(in(i+1), mean(me(i:i+1)), sprintf('%0.3f', diff(me(i:i+1))))
    end
end