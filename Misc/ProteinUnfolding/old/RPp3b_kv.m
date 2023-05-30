function out = RPp3b_kv(inst, inOpts)
%Calc rip transition path histogram

opts.fil = 20; %Filter (smooth, dont downsample)
% opts.meth = 1; %Window method
opts.wid = [200 200]; %Pts to take on each side of the rip

opts.pwlcc = 0.35*127; %Protein size (nm)
% opts.pwlcfudge = 1; %Protein size offset, nm

opts.kvpen = 1e5; %KV stepfinding penalty

opts.verbose = 1; %Debug plots

if nargin > 1
    opts = handleOpts(opts, inOpts);
end


len = length(inst);
tpcrp = cell(1,len);
tpcrpr = cell(1,len);
for i = 1:len
    %Get protein contour
    tmp = inst(i);
    yy = tmp.conpro;
    %Filter
    yf = windowFilter(@mean, yy, opts.fil, 1);
    %Crop
    irng = tmp.ripind - opts.wid (1) : tmp.ripind + opts.wid(2);
    if any(irng < 1 | irng > length(yf))
        %Skip this one
        continue
    end
    yc = yf(irng);
    ycr= yy(irng);
    
    %Save
    tpcrp{i} = yc;
    tpcrpr{i} = ycr;
end
%Remove empty entries if they were skipped
ki1 = ~cellfun(@isempty, tpcrp);

%Remove entries with wild outliers
ki2 = ~ (cellfun(@(x) max(abs(x)), tpcrpr) > opts.pwlcc * 100);

ki = ki1 & ki2;

tpcrp = tpcrp(ki);
tpcrpr = tpcrpr(ki);
inst = inst(ki);

%If these were from multiple files, separate
if isfield(inst, 'file')
    nams = {inst.file};
    [uu, ~, ic] = unique(nams);
    nfil = max(ic);
    for i = nfil:-1:1
        out(i).name = uu{i};
        out(i).tps = tpcrp( ic == i );
        out(i).tpsr = tpcrpr( ic == i );
    end
else
    out.name = '';
    out.tps = tpcrp;
    out.tpsr = tpcrpr;
end

%Then stepfind

for i = 1:length(out)
    %Run Kalafut-Visscher with max 10 steps to find
%     kvmaxsteps = 10;
%     [~, pks] = BatchKV(out(i).tpsr, opts.kvpen, kvmaxsteps, 0);
    %Choose a value of kvmaxsteps that is just a bit larger than the 'expected' number of steps,
    % then choose a value of kvpen that makes K-V find fewer steps than that
    
    %Or run kdfsfind instead? Might be better, since paths are smooth?
    pkloc = kdfsfindV2(out.tpsr, struct( 'verbose', 0, 'kdfmpp', 0.25, 'kdfsd', 1 ) );
    out(i).pks = pkloc;
end


if opts.verbose
    figure, hold on
    %Plot histogram
    for i = 1:length(out)
        [y, x] = nhistc( [ out(i).pks{:} ], 1 );
        plot(x,y)
    end
    legend({out.name})
    xlim( [0 opts.pwlcc] + opts.pwlcc/5 * [-1 1])
end