function renameAsPhage(phgorfx, xwlcparams)

if nargin < 1
    phgorfx = 1;
end
if nargin < 2
    xwlcparams = {40 700};
end

[p, f] = uigetfile('*.mat', 'MultiSelect', 'on');

if ~p
    return
end

if ~iscell(f)
    f = {f};
end

len = length(f);

for i = 1:len
    stepdata= load([p f{i}]);
    fns = fieldnames(stepdata);
    stepdata = stepdata.(fns{1});
    %antony labels extension as dist - rename to my convention
    if isfield(stepdata, 'dist')
        stepdata.extension = stepdata.dist;
    end
    if phgorfx
        %turn vectors into cell
        fns = fieldnames(stepdata);
        if isnumeric(stepdata.(fns{i}))
            stepdata.(fns{i}) = {stepdata.(fns{i})};
        end
        %calculate contour
        stepdata.contour = {stepdata.extension{1} ./ XWLC(stepdata.force{1}, xwlcparams{:})};
        save([p filesep 'Phage' f{i}], 'stepdata');
    else
        ContourData = stepdata; %#ok<NASGU>
        save([p filesep 'ForceExtension' f{i}], 'ContourData');
    end
end