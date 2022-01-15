function out = pol_dwelldist_p2kp(indw, inOpts)

%Input: _p1 output
%Gets pauses per kb


opts.paulen = [0.1 0.5 1 2]; %s, can give multiple

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Batch
if isstruct(indw)
    out = structfun(@(x)pol_dwelldist_p2kp(x, opts), indw, 'Un', 0);
    return
end

%indw is a cell of dwelltimes { [1xn double] }
%Group together multiples
len = sum(cellfun(@length, indw));

out = zeros(length(opts.paulen), 4);
for i = 1:length(opts.paulen)
    tf = cellfun(@(x) x > opts.paulen(i), indw, 'Un', 0); %A boxcar fcn, =1 if a pause
    np = sum( cellfun(@(x) x(1) + sum(diff(x) == 1), tf) ); %Count the number of boxcars = np
    out(i,:) = [np/len sqrt(np)/len np len]; %kp, err, n_pauses, n_dwells
end