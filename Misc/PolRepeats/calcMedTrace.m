function out = calcMedTrace(tra)

opts.dsamp = 50;
opts.prc = 50;

tra = cellfun(@(x) windowFilter(@mean, x, opts.dsamp, 1), tra, 'Un', 0);

%Align by crossing with 0
st = cellfun(@(x) find(x > 0, 1, 'first'), tra);
len = length(tra);
maxlen = max( cellfun(@length, tra) );
tmp = cell(1,len);
for i = 1:len
    a = tra{i}(st(i):end);
    tmp{i} = [ a ones(1, maxlen - length(a))*a(end) ]';
end

tmpall = [tmp{:}];
out = prctile(tmpall, opts.prc, 2)';
% out = median(tmpall, 2)';

% ki = find( isinf(out), 1, 'first');
% out = out(1:ki-1);
