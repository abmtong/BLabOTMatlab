function out = getFirstPulls(inp)
%Get first pulls of files


if nargin < 1
    inp = uigetdir();
end

%Get the ForceExtension files
d = dir(fullfile(inp, 'ForceExtension*.mat'));
d = d(~[d.isdir]);
f = {d.name};
len = length(f);

%Some options
dsamp = 100;
sgf = {1 11};
fmin = 5; %Minimum force for tether break detection

out = cell(1,len);
for i = 1:len
    %Load file
    dat = load(fullfile(inp,f{i}));
    dat = dat.ContourData;
    
    %Grab data
    ext = dat.extension;
    frc = dat.force;
    
    %Grab first pull: Look for first 'local maximum' in trap sep
    % Estimate trap sep
    tsep = ext - dat.forceAX / dat.cal.AX.k  + dat.forceBX / dat.cal.BX.k;
    
    %Downsample
    
    ff = windowFilter(@mean, frc, [], dsamp);
    tf = windowFilter(@mean, tsep, [], dsamp);
    
    %...Take slope with sgolaydiff and find first zero crossing?
    sg = sgolaydiff(double(tf), sgf);
    ind = find(sg<0, 1, 'first');
    % If there is no zero crossing (i.e. break on first pull), use max value
    if isempty(ind)
        ind = length(tf);
    end
    % If this fails, might need to find first local max (i.e., x' = 0 & x'' > 0)
    
    %Crop
    tf = tf(1:ind);
    ff = ff(1:ind);
    
    %Crop tether breaks
    ind = find(ff > fmin, 1, 'last');
    
    %Un-downsample. Use conservative index
    ind = 1 + (ind-1) * dsamp;
    
    %Crop
    ext = ext(1:ind);
    frc = frc(1:ind);
    tsep = tsep(1:ind);
    
    
    %Get name of file, crop ForceExtension*.mat
    nam = f{i}(15:end-4);
    
    out{i} = struct('name', nam, 'ext', ext, 'frc', frc, 'tsep', tsep);
end

out = [out{:}];
