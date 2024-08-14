function out = simhop_wrapper(frc)


if length(frc) > 1
    tmp = arrayfun(@(x) simhop_wrapper(x), frc, 'Un', 0);
    tmp = [tmp{:}];
    tmp = reshape(tmp, 2, [])';
    out = tmp;
    return
end

% out = simhop(tsep, xwlc, trapk, tethertype)
%
%Minimize simhop() - frc


% xwlcparms = {50 900}; %DNA
xwlcparms = {500 3000}; %Origami / DNA-RecA

trapk = .3;

ttype = 1;

dnalen = 700;

fitfcn = @(x) simhop(x, xwlcparms, trapk, ttype, dnalen) - frc;

opt = lsqnonlin(fitfcn, 800, 0, 1e4);

[~, dat] = simhop(opt, xwlcparms, trapk, ttype);

%Get 'dx' from dat

out = abs([diff(dat.ext), diff(dat.frc)]);
