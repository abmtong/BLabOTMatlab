function out = anCondense_backtracking(st, fns )


len = length(fns);
dat = cell(1,len);

compdone = 1500;

for i = 1:len
    tmp = st.(fns{i}).lo;
    %Cut off after compaction is done
    mn = cellfun(@(x) [find(x < compdone, 1, 'first') length(x)], tmp, 'Un', 0);
    
    tmp = cellfun(@(x,y) x(1:y(1)), tmp, mn, 'Un', 0);

    dat{i} = tmp;
end

%A way to quantify backstepping?

vdo.verbose = 0;
vdo.sgp = {1 1001};
vdo.velmult = -1;
vdo.Fs = 1000;
vdo.vbinsz = 5;


figure, hold on
for i = 1:len
    [yy, xx] = vdist(dat{i}, vdo);
    plot(xx,yy)
end
xlim([-2000 2000])
legend(fns)



%Maybe do this instead:
dec = vdo.sgp{2}; %pts

%Do a windowFilter-style downsampling
% fwd = zeros(1,len);
% rev = zeros(1,len);

fwd = cell(1,len);
rev = cell(1,len);
relcond = cell(1,len);
for i = 1:len
    dsampx = cellfun(@(x) windowFilter(@mean, x, [], dec), dat{i}, 'Un', 0);
    vels = cellfun(@(x) diff(x), dsampx, 'Un', 0);
    %And sum pos vs minuses
%     dsampsd = cellfun(@(x) windowFilter(@std, x, [], dec), dat{i}, 'Un', 0);
    %Let's get this fwd vs. rev stats per trace
%     vels = [vels{:}];
    hei = length(vels);
    fwds = zeros(1,hei);
    revs = zeros(1,hei);
    for j = 1:length(vels)
        fwds(j) = -sum( vels{j}( vels{j} < 0)); %Vel downwards is negative, lets negate
        revs(j) = sum( vels{j}( vels{j} > 0));
    end
    fwd{i} = fwds;
    rev{i} = revs;
    rc = fwds ./(revs + fwds);
    %Remove NaNs
    rc = rc(~isnan(rc));
    rc = rc(logical(rc));
    relcond{i} = rc; %Distance compacted / total distance moved
end
% out = [fwd' rev'];

%Plot: relcond beeswarm
%Format data for @beeswarm
for i = 1:len
    xd{i} = i*ones(1,length(relcond{i}));
end
figure, beeswarm([xd{:}]', [relcond{:}]', 'overlay_style', 'sd');
%Add a black line x=0.5
hold on
plot([0 6], [.5 .5], 'k', 'LineWidth', 2)

%Assign labels
labs = get(gca, 'XTickLabel');
for i = 1:length(labs)
    num = str2double(labs{i});
    %Change 1, 2, 3, ... to fns{i}; else blank
    if ~mod(num,1);
        labs{i} = fns{num};
    else
        labs{i} = '';
    end
end
set(gca, 'XTickLabel', labs);

ylabel('Relative distance spent compacting')
out = [ cellfun(@mean, relcond); cellfun(@std, relcond) ; cellfun(@length, relcond) ];

%Do a stepfinding

%Quantify net fwd vs. net backwards steps (total distance)

% for i = 1:len
%     [~, ~, ~, sts] = BatchKV(dat{i}, single(5));
% end



