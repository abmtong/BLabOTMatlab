function out = splitcond3(con, inOpts)

%To be used after splitcond 1/2, to split for size for HMM-based analysis later (RAM issues)

opts.fil = 5;
opts.dy = 1;
opts.maxsz = 1e8; %800MB array max, = 1e8 doubles > pts / fil * (range/dy) ^ 2

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

if ~iscell(con)
    con = {con};
end

out = con;
while true
    %Calculate array sizes
    szs = cellfun(@(x) length(x) / opts.fil * (range(x)/opts.dy)^2 , out);
    %Check for compliance
    tf = szs < opts.maxsz;
    if all(tf);
        break
    end
    %Split those that are too large
    for i = fliplr(find(~tf))
        out = [out(1:i-1) {out{i}(1:round(end/2)-1)} {out{i}(round(end/2):end)} out(i+1:end)];
    end

end
