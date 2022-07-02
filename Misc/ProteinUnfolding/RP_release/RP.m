function out = RP(infp, inOpts)
%Runs RPp1 > RPp2 > RPp3 in a row

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
p1out = RPp1(cd.ContourData, opts);
p2out = RPp2(p1out, opts);
p3out = RPp3(p2out, opts);

out = p3out;

%Check a random three traces
rr = randperm(length(out), 3);
RPcheck(out(rr))