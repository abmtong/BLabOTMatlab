function plotAcorr(y, tfcrop)
%Calculate acorr to determine time constant to downsample to get Markovianness
% Basically take the point at which the diff acorr goes to 0 as the minimum downsampling amount
if nargin < 2
    tfcrop = 0;
end

if tfcrop
    fg = figure; plot(y)
    axis tight
    cr = ginput(2);
    cr = sort(round(cr));
    y = y(cr(1):cr(2));
    delete(fg);
end

%Sampling rate for HMM should be related to f_c for a tether, which is close to f_c for the beads alone
acorlag = 1e3;

%Calculate acorr
ac = xcorr(y,acorlag);
ac = ac(acorlag+1:end);

%Calculate diff(acorr(x)) to try to remove contribution from signal
dac = xcorr( diff(y), acorlag) ;
dac = dac(acorlag+1:end);

x = 0:acorlag;

figure, plot(x,ac/ac(1)), hold on, plot(x,dac/dac(1))
legend({'Acorr' 'Diff Acorr'})
xlim([0 100])