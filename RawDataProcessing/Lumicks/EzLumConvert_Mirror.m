function out = EzLumConvert_Mirror(infp)
%Does mirror calibration from video tracking of a FD curve


verbose = 1; %Plot
askcrop = 1; %Ask for cropping. Flip this to 1 if the fitting is bad because of a nonlinear part

if nargin < 1
    %Get file
    [f, p] = uigetfile('*.h5');
    if ~p
        return
    end
    infp = fullfile(p,f);
end

%Load FD curve
raw = readh5all(infp);

%Get two values
d = raw.Distance_Distance1.Value';
tx = raw.Trapposition_N1X;

%Downsample tx to fit
dsamp = floor( length(tx) / length(d) );
txf = windowFilter(@mean, tx, [], dsamp);
% Will be slightly off since dsamp is integer, but eh
%  So we need to crop txf to be the same length as d1
txf = txf(1:length(d));

out = polyfit(txf, d, 1);

if verbose
    figure, plot(txf, d), hold on, plot(txf, polyval(out, txf))
    [~, f, ~] = fileparts(infp);
    title(sprintf('Mirror Conversion %s', f))
    legend({'Data' 'Fit'})
end

%Maybe do a check for goodness-of-fit?

%Option for cropping
if askcrop
    %Make figure
    figure, plot(txf, d), hold on
    
    %ginput2 to crop the x data
    gi = ginput(2);
    gi = sort(gi(1:2));
    ki = ( txf > gi(1) & txf < gi(2) );
    %Draw crop lines
    yl = ylim;
    line(gi(1)*[1 1], yl, 'Color', 'k')
    line(gi(2)*[1 1], yl, 'Color', 'k')
    
    %Refit with cropped data
    out = polyfit(txf(ki), d(ki), 1);
    
    %Plot, re-title
    plot(txf, polyval(out, txf))
    [~, f, ~] = fileparts(infp);
    title( sprintf('Mirror Conversion %s, cropped data', f) )
    legend({'Data' 'Fit (Cropped)'})
    
    
end






