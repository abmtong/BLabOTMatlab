function prepDcPwebV2p2(nlen)
%Gets a set of three files, *_0.wig, _-1.wig, _1.wig'

if nargin < 1
    nlen = 201;
end

%Select _0.wig
[f, p] = uigetfile('*_0.wig');

%Load and collect data
dat = cell(1,3);
%Do for _0.wig
dat{1} = prepDcPwebV2p2_helper( fullfile(p, f), nlen );
%-1
dat{2} = prepDcPwebV2p2_helper( fullfile(p, [f(1:end-5) '-1.wig']), nlen );
%+1
dat{3} = prepDcPwebV2p2_helper( fullfile(p, [f(1:end-5) '1.wig']), nlen );


figure('Name', 'DNAcycPweb plot', 'Color', [1 1 1])
hold on
%Plot
for i = 1:3
    tmp = mean(dat{i}, 2, 'omitnan');
%     tmpsd = std(dat{i}, 2, 'omitnan');
%     n = size(dat{i},2);
    plot(tmp)
end

%Setup legend
legend({'0' '-' '+'})

%Add line at 'okay' regions. Or at dyad?
xmid = round((1+nlen)/2);
axis tight
yl = ylim;
line(xmid*[1 1], yl)
line(xmid*[1 1]+147/2, yl)
line(xmid*[1 1]-147/2, yl)

