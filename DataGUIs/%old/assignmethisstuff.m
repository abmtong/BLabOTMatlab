function out= assignmethisstuff(filfact, TIME)
if nargin < 1
    filfact = 100;
end

if nargin < 2
    TIME = 100;
end
[f, p] = uigetfile('MultiSelect', 'on');

if ~iscell(f)
    f = {f};
end

len = length(f);

out = [];

for i = len:-1:1
    trace = load([p f{i}]);
    fns = fieldnames(trace);
    fn = fns{1};
    trace = trace.(fn);
    
    tmptime = windowFilter(@mean, trace.time, [], filfact);
    tmpdist = windowFilter(@mean, trace.extension, [], filfact);
    
    tmpdist = tmpdist(tmptime < TIME);
    tmptime = tmptime(tmptime < TIME);
    
%     out.(['T' f{i}(15:end-4)]).dist = tmpdist;
%     out.(['T' f{i}(15:end-4)]).time = tmptime;
    out(i).name = f{i};
    out(i).dist = tmpdist;
    out(i).time = tmptime;

end

    
    