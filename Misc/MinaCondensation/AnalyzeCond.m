function [out, outraw, hmmres] = AnalyzeCond(dat, inOpts)

%Crop with getFCs, split with splitcond2, separate to usable chunks with splitcond3
%eg:
%{
[con , ~, frc] = getFCs();
con2 = splitcond2(con, frc);
dat = splitcond3(con2);
%}


%If struct, batch
if isstruct(dat)
    %Set up batch
    return
end


%Convert to cell
if ~iscell(dat)
    dat = {dat};
end


%Default Opts
opts.fil = 5; %Filter by 5pts
opts.verbose = 1; %Plot ssz dist

%HMM opts
opts.trnsprb = 1e-10;
opts.dy = 1;

if nargin > 1
    opts = handleOpts(opts, inOpts);
end



len = length(dat);
ppool = gcp('nocreate');
hmmres = cell(1,len);
fil = opts.fil;
dy = opts.dy;
trnsprb = opts.trnsprb;
if ~isempty(ppool)
    parfor i = 1:len
        %Create HMM model
        mdl = [];
        mdl.mu = ( floor(min(dat{i})/dy):ceil(max(dat{i})/dy) )* dy;
        mdl.a = ones(length(mdl.mu)) * trnsprb + diag(ones(1,length(mdl.mu)));
        %May need to check maximum size for a / trace length?
        mdl.verbose = 0;
        hmmres{i} = stateHMMV2( windowFilter(@median, dat{i}, [], fil), mdl);
    end
else
    for i = 1:len
        %Create HMM model
        mdl.mu = ( floor(min(dat{i})/dy):ceil(max(dat{i})/dy) )* dy;
        mdl.a = ones(length(mdl.mu)) * trnsprb + diag(ones(1,length(mdl.mu)));
        %May need to check maximum size for a / trace length?
        mdl.verbose = 0;
        hmmres{i} = stateHMMV2( windowFilter(@median, dat{i}, [], fil), mdl);
    end
end

%Extract step sizes
outraw = cellfun(@(x) x.fit, hmmres, 'Un', 0);
[~, me] = cellfun(@tra2ind, outraw, 'Un', 0);
out = cellfun(@(x) abs( diff( x ) ), me, 'Un', 0);

if opts.verbose
    figure, hold on
    plot(linspace(0,1, length([out{:}])), sort([out{:}]))
    
    outraw = cellfun(@(x) x.fitnoopt, hmmres, 'Un', 0);
    [~, me] = cellfun(@tra2ind, outraw, 'Un', 0);
    out2 = cellfun(@(x) abs( diff( x ) ), me, 'Un', 0);
    plot( linspace(0,1, length([out2{:}])), sort([out2{:}]));
    
    outraw = cellfun(@(x) x.fitmle, hmmres, 'Un', 0);
    [~, me] = cellfun(@tra2ind, outraw, 'Un', 0);
    out3 = cellfun(@(x) abs( diff( x ) ), me, 'Un', 0);
    plot(linspace(0,1, length([out3{:}])), sort([out3{:}]));
end