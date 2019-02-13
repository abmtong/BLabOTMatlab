function PlotTracesRecurse(varargin)

path = uigetdir();
d = dir(path);
dnames = {d.name};
dnames = dnames([d.isdir]);
dnames = dnames(3:end); %remove '.' and '..'

fold = fileparts(path);

figure('Name',['PlotTracesRecurse ' fold])
ax = gca;

for i = 1:length(dnames)
    PlotTraces('Path', [path filesep dnames{i} filesep], 'Axis', ax, varargin{:})
end
