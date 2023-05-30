function out = RP(infp, inOpts)
%Runs RPp1 > RPp2 > RPp3 > RPp4 in a row

if nargin < 1 || isempty(infp)
    [f, p] = uigetfile('*.mat', 'Mu', 'on');
    if ~p
        return
    end
    if ~iscell(f)
        f = {f};
    end
    infp = cellfun(@(x)fullfile(p, x), f, 'Un', 0);
end

if nargin > 1
    opts = inOpts;
else
    opts = [];
end


if iscell(infp)
    out = cellfun(@(x)RP(x, opts), infp, 'Un', 0);
    %Add file field
    for i = 1:length(out)
        [~, f, ~] = fileparts(infp{i});
        [out{i}.file] = deal(f);
    end
    %And combine
    out = [out{:}];
    return
end

cd = load(infp);
%Make sure there's a ContourData field
if ~isfield(cd, 'ContourData')
    [~, f, ~] = fileparts(infp);
    warning('No ContourData found in file %s', f)
    return
end

%Run RP
%P1: Extract pulling cycles
p1out = RPp1(cd.ContourData, opts);
%P2: Separate pull and relax ; find rip
p2out = RPp2(p1out, opts);
%P3: Fit pull to XWLC, calculate protein contour
p3out = RPp3(p2out, opts);
% P3_avg: Then reconvert with average XWLC values (as opposed to per-pull)
p3out = RPp3_avg(p3out, opts);
%P4: Find relax refold. Takes some time; could be better
% p4out = RPp4(p3out, opts);

%Save this struct
out = p3out;
% out = p4out;

%Check a random three traces
rr = randperm(length(out), min(length(out), 3));
RPcheck(out(rr))

%Run histograms
%P3b: Unfolding histogram
RPp3bV2(out);
%P3b_kv: Unfolding histogram (stepfinding)
% RPp3b_kv(out);
%P4b: Refolding histogram
% RPp4b(out);