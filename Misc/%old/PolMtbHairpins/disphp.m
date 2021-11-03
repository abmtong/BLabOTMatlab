function disphp(seq, hps)

%Display hairpins for hps in seq
%Requires knowing wid
wid = 30;

for i = 1:size(hps,1)
    fprintf('Hairpin %d: %dnt, Loop size %dnt, score %d\n', i, hps(i,:))
    tmpa = seq( hps(i,1)-1 + (wid:-1:1) );
    tmpb = seq( hps(i,1)-1 + hps(i,2) + wid + (1:wid) );
    lp   = seq(hps(i,1)-1+wid+ (1:hps(i,2)));
    
    fprintf('%s\n',[lp tmpb])
    fprintf('%s\n', [repmat(' ', 1, length(lp)) tmpa])
    fprintf('\n')
end