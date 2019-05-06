function FCrescale_save(cropstr)
if nargin < 1
    cropstr = '';
end
[f, p] = uigetfile('phage*.mat', 'Mul', 'on');
if ~p
    return
end
if ~iscell(f)
    f={f};
end

newp = [p filesep 'FCrescaled' cropstr filesep];
if ~exist(newp, 'dir')
    mkdir(newp)
end
for i = 1:length(f)
    stepdata = FCrescale([p f{i}],cropstr); 
    if ~isempty(stepdata)
        save([newp f{i}], 'stepdata');
    end
end