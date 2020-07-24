function cleanupPhage(filepath, minLen)
%Removes feedback cycles that are less than a certain number of points
%Ghe's code is very poor at finding cycles for higher frequency data (= more noise in mirror_X)

%Say 0.1s is our cutoff; normal data is 2.5kHz -> cutoff is 250 pts
if nargin < 2 || isempty(minLen)
    minlen = 250;
end

if nargin < 1 || isempty(filepath)
    [file, path] = uigetfile();
    if ~path
        return
    end
    filepath = [path file];
end

%This loads the struct stepdata
load(filepath)

lens = cellfun(@length,stepdata.time); %#ok<NODEF>

keepind = lens>minlen;

%hard coded fieldnames, could do programatically with: 
fns = fieldnames(stepdata);

for i = 1:length(fns)
    if iscell(stepdata.(fns{i}))
        temp = stepdata.(fns{i});
        stepdata.(fns{i}) = temp(keepind);
    end
end

save(filepath, 'stepdata')