function [ax, rawcon] = lof2pwd(incropstr, inOpts)

if nargin < 1
    incropstr = '11';
end

%declare options:
%opts for pwd

%opts for this fcn
opts.verbose = 1;

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%loads crops by incropstr
[rawcon, ~, ~, rawtrn] = getFCs(incropstr);
%rearrange them to cells-of-cells
len = length(rawcon);
rawcon2 = cell(1, max(rawtrn));
for i = 1:len
    rawcon2{rawtrn(i)} = [rawcon2{rawtrn(i)} rawcon(i)];
end
rawcon2 = rawcon2(~cellfun(@isempty, rawcon2));
len = length(rawcon2);
%get each, test for "steppiness" by eye
% ax = gobjects(1,len);
pw = cell(1,len);
for i = 1:len
    [pw{i}, xx] = sumPWDV1b(rawcon2{i});
    delete(gcf);
end
figure, hold on
ax = gobjects(1,len);
for i = 1:len
    ax(i) = plot(xx, pw{i}/pw{i}(1) + i * .1);
end
waitfor(figure('Name', 'Delete bad lines in other figure, close this to continue'));

% ax = [ax{:}];
% ax=ax(isvalid(ax));
rawcon2 = rawcon2(isvalid(ax));
if isempty(rawcon2)
    return
end

%calc PWD, with and without cherry
sumPWDV1bmatrix(rawcon);
sumPWDV1bmatrix([rawcon2{:}]);

%assign, plot
if opts.verbose
    figure, plot(x, vpdf, 'o'), hold on, 
    plot(x, fp, 'LineWidth', 2, 'Color', 'k')
    plot(x, npdf(fit(1:3),x), ':', 'LineWidth', 1.5, 'Color', 'k')
    plot(x, npdf(fit(4:6),x), '--', 'LineWidth', 1, 'Color', 'k')
    line(fit(4) * [1 1], [0 max(fp)*2], 'LineStyle', '--', 'LineWidth', 1, 'Color', 'k')
    fprintf('Speed %0.2f +- %0.2f nm/s, %0.2f pct paused\n', fit(4:5), fit(3))
end
%show no cmd line out if not assgnd
if nargout > 0
    if opts.verbose
        ax = gca;
    else
        ax = [];
    end
end