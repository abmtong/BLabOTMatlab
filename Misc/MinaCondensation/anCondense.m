function out = anCondense(trs, inOpts)

opts.ycut = 1500; %bp, cut traces once they cross here. To remove end pausing?
opts.tcut = 10; %s, cut traces after this length of time

%Define vdist options
opts.sgp = {1 201}; %"Savitzky Golay Params"
opts.vbinsz = 10; %Velocity BIN SiZe
opts.Fs = 1e3; %Frequency of Sampling
opts.velmult = -1;%Set decreasing to positive
opts.vfitlim = [-inf inf]; %Velocity to fit over
opts.verbose = 0;

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

len = length(trs);

%Cut some traces ... somewhere
for i = 1:len
    %Time cutoff
    trs{i} = cellfun(@(x) x(1:min(length(x), round(opts.tcut*opts.Fs))), trs{i}, 'Un', 0);
    %Length cutoff
    iend = cellfun(@(x) find( x < opts.ycut, 1, 'first'), trs{i}, 'Un', 0);
    lens = cellfun(@length, trs{i}, 'Un', 0);
    iend( cellfun(@isempty, iend) ) = lens( cellfun(@isempty, iend) );
    trs{i} = cellfun(@(x,y) x(1:y), trs{i}, iend, 'Un', 0);
end


[vy, vx] = cellfun(@(x) vdist(x, opts), trs, 'Un', 0);

figure('Name', 'anCondense', 'Color', [1 1 1])
hold on
cellfun(@(x,y,z) plot(x,y,'Color', z), vx, vy, arrayfun(@(x) hsv2rgb(x, 1, .7), (0:length(vx)-1)/length(vx), 'Un', 0)  )

[~, out] = vdist_batch(trs, opts);

%Get height at 0vel
zwid = 50; %Use zero height as average over -zwid:zwid
hts = cellfun(@(x,v) mean( v( x <=zwid & x >=-zwid ) ) , out.x, out.v);

%Use second as 'noise baseline' and subtract away
indbase = 2;
vsub = cell(1,len);
for i = 1:len
    %Assume x values are aligned
    lox = max( min( out.x{i}), min( out.x{indbase} ) );
    hix = min( max( out.x{i}), max( out.x{indbase} ) );
    %Get indicies in both x-coords
    ind1 = find(out.x{i} == lox, 1, 'first') : find(out.x{i} == hix, 1, 'first'); %might need to use eps-compare?
    ind2 = find(out.x{indbase} == lox, 1, 'first') : find(out.x{indbase} == hix, 1, 'first');
    %And subtract
    vsub{i} = out.v{i};
    vsub{i}(ind1) = vsub{i}(ind1) - out.v{indbase}(ind2) / hts(indbase) * hts(i);
end
out.vsub = vsub;

figure, hold on, cellfun(@plot, out.x, out.vsub)
figure, hold on, cellfun(@(x,y,z)plot(x,y/z), out.x, out.v, num2cell(hts))




