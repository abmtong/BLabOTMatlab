function out = processAPDScan(dat)
%Process an APD scan, input is output of loadfile_wrapper.
% If nargin == 0, then prompts user for a file
%Plot with e.g. figure, surface([out{:}], 'EdgeColor', 'none'), axis equal

if nargin < 1
    %Get from file
    [f, p] = uigetfile('Choose a scan .dat','*.dat');
    if ~p
        return
    end
    %Load file. Assume this can be loaded with Meitner defaults.
    op.Instrument = 'Meitner';
    fp = fullfile(p,f);
    
    dat = loadfile_wrapper(fp, op);
end

%Get metadata
meta = dat.meta;

%Load data
a1 = dat.APD1;
a2 = dat.APD2;

%Downsample
a1 = windowFilter(@sum, a1, [], meta.apdNSampPerStep);
a2 = windowFilter(@sum, a2, [], meta.apdNSampPerStep);

%Reshape
a1 = reshape(a1, meta.scanNStepsX*2, meta.scanStepsYorNScans);
a2 = reshape(a2, meta.scanNStepsX*2, meta.scanStepsYorNScans);

%Average across left and right scan
a1 = a1(1:end/2,:) + a1( end:-1:end/2+1, :);
a2 = a2(1:end/2,:) + a2( end:-1:end/2+1, :);

out = {a1' a2'};




