function [out, outraw] = pol_dwelldist_vdist(dat, inp1tr, inOpts)
%Take dat and datp1, remove dwells over dwellthr in length, then send result to vdist


opts.Fs = 1e3; %Hz
opts.maxdw = 0.5; %Seconds

opts.verbose = 0; %Show trace cropping or not

%@vdist options
opts.vdist.sgp = {1 101}; %S-G params
opts.vbinsz = 0.5; %Velocity BIN SiZe
opts.vdist.verbose = 0;
opts.vdist.velmult = -1;

if nargin > 2
    opts = handleOpts(opts,inOpts);
end

opts.vdist.Fs = opts.Fs;

if isstruct(dat)
    datc = struct2cell(dat);
    inp1trc = struct2cell(inp1tr);
    [~, outraw] = cellfun(@(x,y)pol_dwelldist_vdist(x,y,opts), datc, inp1trc, 'Un', 0);
    out = vdist_batch(outraw, opts.vdist);
    return
end

%If not cell, make cell
if ~iscell(dat)
    dat = {dat};
    inp1tr = {inp1tr};
end

len = length(dat);
trcrps = cell(1,len);
maxpts = opts.maxdw * opts.Fs;
for i = 1:len
    dt = dat{i};
    in = tra2ind(inp1tr{i});
    dws = diff(in);
    ki = dws < maxpts;
    tf = ind2tra(in, ki);
    st = find( diff([0 tf]) ==  1 );
    en = find( diff([tf 0]) == -1 );
    trcrps{i} = arrayfun(@(x,y) dt(x:y), st, en, 'Un', 0);
    
    if opts.verbose
        dtsm = windowFilter(@mean, dt, opts.vdist.sgp{2}, 1);
        figure, surface( repmat( (1:length(dt))/opts.Fs, [2 1]), [dtsm; dtsm], zeros(2, length(dt)), [tf; tf], 'EdgeColor', 'interp')
    end
    
end

%Gather
outraw = [trcrps{:}];

%Pass to vdist
[vdn, vdx] = vdist(outraw, opts.vdist);
out = [vdx' vdn'];









