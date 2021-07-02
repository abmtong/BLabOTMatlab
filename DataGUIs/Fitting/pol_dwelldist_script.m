%Pol_dwelldist script, does everything you'd want
%Crop your data and assemble the conditions into a struct called rawdat
%e.g.: 
%{
Step 1: Crop traces in PhageGUI
 see PhageGUI usage

Step 2: Assemble raw data struct
 Extract traces using getFCs:
  data1 = getFCs(); %Select trace, set 1
  data2 = getFCs(); %Select trace, set 2
  %etc.
 Assemble them to a struct by condition, e.g.
  rawdata.condition1 = data1;
  rawdata.condition2 = data2;
%}

%Default is assisting force (trace extends over time), else change the below line
assistingForce = 1; %Make 0 if opposing force (tether length decreases over time)
Fs = 1e3;
redocalc = 0; %Set to 1 to force redo all calculations

if ~exist('rawdat', 'var')
    error('Make sure you name your data ''rawdat''')
end

%Create options
pdd1opts.Fs = Fs; %Or whatever your Fs is
if assistingForce
    pdd1opts.dir = 1;
    pdd1opts.fvopts = struct('dir', 0, 'trnsprb', [1e-3, 1e-100], 'ssz', 1);
else
    pdd1opts.dir = -1;
    pdd1opts.fvopts = struct('dir', 0, 'trnsprb', [1e-100, 1e-3], 'ssz', 1);
end
pdd2opts = struct( 'xrng', [2/Fs, inf], 'prcmax', 99.9, 'nmax', 8, 'fitsing', 0);
pdd3bopts = struct('Fs', Fs, 'bstrap', 1);

%Do p1, call it p1out
if redocalc || ~exist('p1out', 'var')
    parpool %p1 supports parpool, so start one for speed
    [p1out, p1bt, p1tr] = pol_dwelldist_p1(rawdat, pdd1opts); %Fit staircase to data
end
%Plots the trace fitting

%Do p2, call it p2out
if redocalc || ~exist('p2out', 'var')
    p2out = pol_dwelldist_p2(p1out, pdd2opts); %Fit dwells to exponentials
end
%Plots the dwell fitting and the a/k bar graph

%Always do p3, I guess
[p3out, p3kn] = pol_dwelldist_p3b(rawdat, p1tr, p2out, pdd3bopts); % Colorize trace by dwell length, calculate randomness p-values
%Plots the dwells colored by dwell length and the pause probability

fprintf('Check that the fittings look ''okay'', and consider using >saveall to save the figures and workspace\n')

