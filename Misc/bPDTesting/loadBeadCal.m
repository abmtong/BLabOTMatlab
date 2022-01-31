function out = loadBeadCal()

[f, p] = uigetfile('*.dat');
infp = [p f];

if ~p
    return
end

calopts.Instrument = 'HiRes';
calopts.Fs = 3.5e6;
calopts.lortype = 1;
calopts.Fmax = 0.2e5; %2e4;

%Calibrate
cal = ACalibrateV2(infp, calopts);

%Load file
dat = loadfile_wrapper(infp, calopts);

% %Get right sum if needed -- ACTUALLY calibration uses only half of sum, so ignore
% if isbpd(1)
%     dat.AS = dat.AS + dat.AY;
% end
% 
% if isbpd(2)
%     dat.BS = dat.BS + dat.BY;
% end

%Apply offset (mean) and calibration for AX and BX to get nm
a = -dat.AX ./ dat.AS;
a = a - mean(a);
a = a * cal.AX.a;


b = dat.BX ./ dat.BS;
b = b - mean(b);
b = b * cal.BX.a;

t = (1:length(a))/calopts.Fs*1e6;

c = windowFilter(@mean, b, 17, 1); %Filter B to 100kHz

nmax = 1e5;
figure, plot(t(1:nmax), a(1:nmax)), hold on, plot(t(1:nmax), b(1:nmax)), plot(t(1:nmax), c(1:nmax))
ylabel Position(nm)
xlabel Time(us)

[msda, acra] = msdFFT(a);
[msdb, acrb] = msdFFT(b);
msdlen = 1e3;

figure, plot( (1:msdlen)/3.5 , msda(1:msdlen) )
hold on, plot( (1:msdlen)/3.5 , msdb(1:msdlen) )
ylabel MSD(nm^2)
xlabel Time(us)

figure, plot( (1:msdlen)/3.5 , acra(1:msdlen) )
hold on, plot( (1:msdlen)/3.5 , acrb(1:msdlen) )
ylabel Autocorrelation
xlabel Time(us)

out.a = a;
out.b = b;
out.araw = -dat.AX;
out.braw = dat.BX;
% out.dat = dat;
[~, fi, ~] = fileparts(infp);
out.nam = fi;









