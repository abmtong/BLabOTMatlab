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
a = {dat.APD1 dat.APD2};
if isfield(dat, 'APD3')
    a{3} = dat.APD3;
end

%Get scan params
if isfield(meta, 'APDdsamp')
    dsamp = meta.apdNSampPerStep / meta.APDdsamp;
else
    dsamp = meta.apdNSampPerStep;
end
scanX = meta.scanNStepsX;
scanY = meta.scanStepsYorNScans;
npx = scanX*2*scanY;

%Downsample
a = cellfun(@(x) windowFilter(@sum, x, [], dsamp), a, 'Un', 0);
% a1 = windowFilter(@sum, a1, [], dsamp);
% a2 = windowFilter(@sum, a2, [], dsamp);

%Reshape. Trim if scan goes a bit longer
a = cellfun(@(x) reshape(x(1:npx), scanX*2, scanY), a, 'Un', 0);

% a1 = reshape(a1(1:npx), scanX*2, scanY);
% a2 = reshape(a2(1:npx), scanX*2, scanY);

%Average across left and right scan
a = cellfun(@(x) x(1:end/2,:) + x( end:-1:end/2+1, :), a, 'Un', 0);
% a1 = a1(1:end/2,:) + a1( end:-1:end/2+1, :);
% a2 = a2(1:end/2,:) + a2( end:-1:end/2+1, :);

out = a;




