function cutnshow(gn, site)

[st, en] = regexp(gn, site);

wid = 20; %nt to show on either side

if ~any(st)
    fprintf('Site %s is a non-cutter for input %s', site, inputname(1))
    return
end
len = length(gn);
n = length(st);

%make uppercase
gn = upper(gn);
site = upper(site);

function out = compl(in)
    in(in=='A') = 't';
    in(in=='T') = 'a';
    in(in=='G') = 'c';
    in(in=='C') = 'g';
    out = upper(in);
end

figure('Name', sprintf('CutNShow site %s input %s', site, inputname(1)))
for i = 1:n
    snip = gn( max(st(i)-wid, 1):min(en(i)+wid, len));
    text(0,i,sprintf('%s\n%s', snip, compl(snip)), 'FontName', 'FixedWidth')
end
ylim(.5+[0 n])
xlim([0 3])
end