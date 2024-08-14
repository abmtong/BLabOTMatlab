function [frcbar, out] = simhop(tsep, xwlc, trapk, tethertype, dnalen)
%

%Made to compare with origami, by changing XWLC params


opts.trapk = 0.3; %pN/nm

if nargin >=3 && ~isempty(trapk)
    opts.trapk = trapk;
end

opts.trapsep = 810; %Trap sep, nm

if nargin >= 1 && ~isempty(tsep)
    opts.trapsep = tsep;
end

if nargin < 5
    opts.dnalen = 700; %tether length, nm
else
    opts.dnalen = dnalen;
end

 
opts.dnaxwlc = {35 900}; %DNA XWLC params . Shaw paper is ~35nm/900pN/980nm
opts.dnaxwlc = {3000 900}; %Origami XWLC params?
opts.dnaxwlc = {400 900}; %Origami XWLC params. Shaw is ~400nm/900pN/949nm

if nargin >= 2 && ~isempty(xwlc)
    opts.dnaxwlc = xwlc;
end

opts.ripsz = .35*155; %155aa

if nargin >= 4 && ~isempty(tethertype)
else
    tethertype = 2;
end
switch tethertype
    case 1 %Polypeptide
        opts.ripxwlc = {.5 inf};
%         fprintf('Polypeptide rip\n')
    case 2 %Unstretchable
        opts.ripxwlc = {1e10 inf};
        fprintf('Unstretchable rip\n')
    case 3 %DNA
        opts.ripxwlc = {35 900};
        fprintf('DNA rip\n')
end



opts.k = 1e-3; %transition rate, both sides
nstep = 20;

%Set RNG seed, so hops are the same
a = rng(0); %Save current rng, then set rng seed to 0

%Get ext, force of tether, folded
%              trap sep = 2*dx + XWLC(F, params) * contour
fitfcn = @(x) opts.trapsep - 2 * x - XWLC(opts.trapk * x, opts.dnaxwlc{:}) * opts.dnalen;
lsqopts = optimoptions('lsqnonlin');
lsqopts.Display = 'none';
bdeff = lsqnonlin(fitfcn, 1, 0, inf, lsqopts);
extf = opts.trapsep - 2 * bdeff;
frcf = bdeff*opts.trapk;

%And unfolded
fitfcnu = @(x) opts.trapsep - 2 * x - XWLC(opts.trapk * x, opts.dnaxwlc{:}) * opts.dnalen - XWLC(opts.trapk * x, opts.ripxwlc{:}) * opts.ripsz;
bdefu = lsqnonlin(fitfcnu, 1, [], [], lsqopts);
extu = opts.trapsep - 2*bdefu;
frcu = bdefu*opts.trapk;


%Create dwells
dw = exprnd(1/opts.k, 1, nstep);
in = cumsum(ceil(dw));
in = [1 in+1];

%Create steps
me = mod(1:nstep, 2)+1;
mu = [extf extu];
me = mu(me);


tra = ind2tra(in,me);


% fprintf('Forces: %0.2f, %0.2f\n', frcf, frcu);

% if nargout
    out.tra = tra;
    out.ext = [extf extu];
    out.frc = [frcf frcu];
% else
%     figure('Name', sprintf('Trap Sep: %0.2fnm, Force: %0.2fpN (%0.2f, %0.2f), dx: %0.2fnm\n', opts.trapsep, frcf/2+ frcu/2, frcf, frcu, diff(mu)));
%     plot(tra)
% end

frcbar = mean(out.frc);

rng(a); %Return to original rng
