function PlotElro()

[f, p] = uigetfile('*.mat', 'mu', 'on');
if ~iscell(f)
    f = {f};
end

if ~p
    return
end

%plot all traces, separate by method
%need Output and Mode fields
ops = {'-', 'Torque', 'Trap'};
mos = {'-', 'Constant', 'Constant Speed', 'Stepwise', 'Fixed', 'Designed'};

%So we'll need at most six graphs
axs = gobjects(length(ops),length(mos));
for i = 1:length(f)
    %Load file
    eldata = load(fullfile(p, f{i}));
    eldata = eldata.eldata;
    opin = find(strcmpi(ops, eldata.inf.Output));
    moin = find(strcmpi(mos, eldata.inf.Mode));
    
    if any(isempty([opin, moin]))
        fprintf('PlotElro: %s skipped because invalid fieldname: %s, %s\n', f{i}, eldata.inf.Output, eldata.inf.Mode)
        continue
    end
    
    %Check if axes exist for that type of data
    if ~isgraphics(axs(opin,moin))
        fg = figure('Name', sprintf('PlotElro: %s, %s', ops{opin}, mos{moin}));
        axs(opin,moin) = axes(fg); %#ok<LAXES>
        hold on
        axis tight
    end
    %And plot. I've seen the length of the two be different, so calculate the length
    plen = min(length(eldata.time), length(eldata.rotlong));
    plot(axs(opin, moin), eldata.time(1:plen), eldata.rotlong(1:plen))
    text(axs(opin, moin), eldata.time(end), eldata.rotlong(end), f{i}(1:end-4))
end
    

