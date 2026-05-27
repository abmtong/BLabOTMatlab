function out = sumNucHist_fluor(drA, fl, inOpts)



opts.shift = [
opts.Fs = 4e3/3; %Contour FSamp
opts.flFs = 1e3; %Fluorescence FSamp
opts.flDsamp = 1e3; %Downsampling for fluorescence (to get okay counts)

opts.flfield = 'apd1'; %Choose which APD to plot, 'apd1' or 'apd2' ... implement others (FRET, LaserChoice, etc.)

%Get data
flt = fl.apdT;
fly = fl.(opts.flfield);

%Match sampling for... fl... ? And just plot ext-fluor? Like SNH

