function out = ezPlotGreen(infps)

if nargin < 1
    [f p ] = uigetfile('Mu', 'on');
    if ~p
        return
    end
    if ~iscell(f)
        f = {f};
    end
    
    infps = cellfun(@(x) fullfile(p, x), f, 'Un', 0);
end

len = length(infps);
out = cell(1,len);
for i = 1:len
    cd = load(infps{i});
    
    cd = cd.ContourData;
    
    out{i} = cd.apd1;

end

%Filter for plotting

grn = [out{:}];
grn = double(grn);
grn = windowFilter(@mean, grn, 25, 1);
tt = (1:length(grn)) / 1e3; %Assumes 1kHz
figure, plot(tt, grn)