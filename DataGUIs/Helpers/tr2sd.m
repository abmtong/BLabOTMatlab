function tr2sd(type)
if nargin < 1
    type = 1; %Timeshared and FleezersAnalysis (Antony)
end

[f, p] = uigetfile('*.mat', 'Mu', 'on');

if ~p
    return
end

if ~iscell(f)
    f = {f};
end
mkdir(fullfile(p, 'PhageConverted'))
for i = 1:length(f)
    stepdata = load([p f{i}]);
    switch type
        case 1
            %struct name is trace
            %vector fields are: time, dist, force, trap_sep
            %metadata: unit [nm or bp], path, info
            stepdata = stepdata.trace;
            stepdata.time = {stepdata.time};
            stepdata.force = {stepdata.force};
            
            %Auto convert to contour here
            stepdata.xwlc = [40 900 .34];
            if strcmp(stepdata.unit ,'nm')
                stepdata.extension = {stepdata.dist};
                stepdata.contour = {stepdata.dist ./ XWLC(abs(stepdata.force{1}), stepdata.xwlc(1), stepdata.xwlc(2)) / stepdata.xwlc(3)};
            else
                stepdata.contour = {stepdata.dist};
                stepdata.extension = {stepdata.dist .* XWLC(abs(stepdata.force{1}), stepdata.xwlc(1), stepdata.xwlc(2)) * stepdata.xwlc(3)};
            end
            stepdata = rmfield(stepdata, 'dist'); %#ok<NASGU>
            save(fullfile(p, 'PhageConverted', ['phage' f{i}]), 'stepdata')
        otherwise
    end
end
