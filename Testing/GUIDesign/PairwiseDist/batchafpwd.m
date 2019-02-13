function out = batchafpwd(inp, inf)

if nargin<2
    if nargin < 1
        defpath = 'C:\Data\phage*.mat';
    else
        defpath = inp;
    end
    [inf, inp] = uigetfile(defpath,'Pick phage files','MultiSelect', 'on');
    if ~iscell(inf)
        inf = {inf};
    end
end
len = length(inf);
out = cell(1, len);
for i = 1:len
    sd = load([inp filesep inf{i}]);
    sd = sd.stepdata;
    out{i} = autofindPWD(sd);
end

out = [out{:}];