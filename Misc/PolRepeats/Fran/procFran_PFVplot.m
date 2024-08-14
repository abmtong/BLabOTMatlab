function procFran_PFVplot(out, nams)

%Basically, we can just take stats along dim 2

mn = cellfun(@(x) mean(x,2,'omitnan'), out, 'Un', 0);
sd = cellfun(@(x) std(x, [], 2, 'omitnan'), out, 'Un', 0);
nn = cellfun(@(x) sum(~isnan(x), 2), out, 'Un', 0);

nr = length(mn{1});

%Concatenate. This is now [roi1(:) roi2(:) roi3(:) ...]
mn = [mn{:}]';
sd = [sd{:}]';
nn = [nn{:}]';

%Add a 0 spacer between ROIs
mn = [mn; zeros(1, nr)];
sd = [sd; zeros(1, nr)];
nn = [nn; ones(1, nr)];
sem = sd ./ sqrt(nn);

%Plot as bar + errors
figure, hold on
bar( mn(:) )
% errorbar(mn(:), sd(:)./nn(:), 'LineStyle', 'none')
errorbar(mn(:), sem(:), 'LineStyle', 'none')

%Create x tick labels
xt = 1:numel(mn)-1;
nams = repmat( [nams {[]}] , 1, nr );
nams = nams(1:end-1); %Strip final empty string
ax = gca;
ax.XTick = xt;
ax.XTickLabel = nams;
ax.XTickLabelRotation = 90;

xlim( xt([1 end]) + [-1 1] )

xlabel('Region: Repeats | 601')
ylabel('Pause-free velocity (bp/s)')