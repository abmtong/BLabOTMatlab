%Process data
addpath('..\Timeshare Processing')
[~, outfp] = tsprocess;
%Select data, offset, then cal file (hold control) (in that order!)
%You should now have a DataMMDDYY_NNN.mat file in the folder
%Load it, then extract the data
load(outfp)
ext = tsdata.extension;
frc = tsdata.force;
%Crop the thing by choosing left and right bounds
figure('Name', 'Choose left and right crop bounds'), plot(ext), gi = ginput(2);
inds = round(sort(gi(1:2)));
crp = @(x) x(inds(1):inds(2));
ext = crp(ext);
frc = crp(frc);

%To run, use this command:
%polpause( extension, [sgfrank, sgfwidth], [sampfreq, dsampfactor], {xwlcforce, pl, sm, kt} )
polpause(ext, [1 133], [4e3/3 13], {frc 30 1200 4.14})