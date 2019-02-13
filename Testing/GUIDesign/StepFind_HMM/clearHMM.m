function clearHMM()

[f, p] = uigetfile('pHMM*.mat', 'MultiSelect', 'on');

if ~iscell(f)
    f = {f};
end

mkdir([p filesep 'stripped'])

for i = 1:length(f)
    fcdata = load([p f{i}]);
    fcdata = fcdata.fcdata;
    if isfield(fcdata,'hmm')
        fcdata = rmfield(fcdata, 'hmm');
    end
    if isfield(fcdata, 'hmmfinished')
        fcdata = rmfield(fcdata, 'hmmfinished');
    end
    if isfield(fcdata, 'aseed')
        fcdata = rmfield(fcdata, 'aseed');
    end
    save([p filesep 'stripped' filesep f{i}], 'fcdata')
end