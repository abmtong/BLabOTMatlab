function [out, outraw] = pol_dwelldist_vdist(dat, inp1tr, inOpts)
%Take dat and datp1, remove dwells over dwellthr in length, then send result to vdist


opts.Fs = 1e3; %Hz
opts.maxdw = 0.5; %Seconds

opts.verbose = 0; %Show trace cropping or not
opts.verbosefil = 10; %Filter amt for trace cropping

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
%     [~, outraw] = structfun(@(x,y)pol_dwelldist_vdist(x,y,opts), dat, inp1tr);
    datc = struct2cell(dat);
    fns = fieldnames(dat);
    inp1trc = struct2cell(inp1tr);
    [~, outraw] = cellfun(@(x,y)pol_dwelldist_vdist(x,y,opts), datc, inp1trc, 'Un', 0);
    prestr = [fns ; outraw];
    outraw = struct(prestr{:});
    out = vdist_batch({outraw.tloc}, opts.vdist);
    %ABOVE MIGHT NOT WORK
    
    figure('Name', 'Pause Dists')
    hold on
    pcc = @(x) plot( sort(x), (1:length(x))/length(x));
    cellfun(@(x) pcc(cellfun(@length, x)), {outraw.pcc})
    legend( fieldnames(dat) )
    return
end

%If not cell, make cell
if ~iscell(dat)
    dat = {dat};
    inp1tr = {inp1tr};
end

len = length(dat);
trcrps = cell(1,len);
trpaus = cell(1,len);
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
    st = find( diff([0 ~tf]) ==  1 );
    en = find( diff([~tf 0]) == -1 );
    trpaus{i} = arrayfun(@(x,y) dt(x:y), st, en, 'Un', 0);
    
    if opts.verbose
        dtsm = windowFilter(@mean, dt, opts.verbosefil, 1);
        figure
        plot( (1:length(dt))/opts.Fs, dtsm, 'Color', [.7 .7 .7])
        hold on
        surface( repmat((1:length(dt))/opts.Fs, [2 1]) , repmat( inp1tr{i} , [2 1]), zeros(2, length(dt)), [tf; tf], 'EdgeColor', 'interp', 'LineWidth', 2)
        colormap ([1 0 0; 0 1 0]) %Red = no, Grn = yes
    end
    
end

%Gather
outraw.tloc = [trcrps{:}];
outraw.pau = [trpaus{:}];

%Pass to vdist
[vdn, vdx] = vdist(outraw.tloc, opts.vdist);
out = [vdx' vdn'];

ntloc = cellfun(@range, inp1tr);
npau = cellfun(@length, trpaus);

outraw.paus = [ntloc' npau']; %[total_bp n_pauses] = sum(paus,1)









