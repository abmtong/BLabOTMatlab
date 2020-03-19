function [stps, dwls, stpsmle, dwlsmle] = hmmhist(inst, nitermax, useopt)
%reads hmm data, plots hist of step sizes (instead of sum of trns matrix)

if nargin < 1 || isempty(inst)
    [f, p] = uigetfile('.\pHMM*.mat','MultiSelect','on');
    if ~p
        return
    end
    if ~iscell(f)
        f = {f};
    end
    len = length(f);
    for i = len:-1:1
        %load
        fcdata = load([p f{i}]);
        inst(i) = fcdata.fcdata;
    end
end

if nargin < 2
    nitermax = 5;
end
if nargin < 3
    useopt = 1;
end

len = length(inst);
stps = cell(1,len);
dwls = cell(1,len);
stpsmle = cell(1,len);
dwlsmle = cell(1,len);

for i = 1:len
    curhmm = inst(i).hmm;
    if inst(i).hmmfinished == -1
        continue
    end
    maxiter = length(curhmm);
    if useopt
        optiter = max(inst(i).hmmfinished, 1);
    else
        optiter = inf;
    end
    useiter = min([nitermax, optiter, maxiter]);
    [ind, mea] = tra2ind(curhmm(useiter).fit);
    stps{i} = diff(mea);
    dwls{i} = diff(ind) / 2500; %or whatever Fs is
    
    if isfield(curhmm, 'fitmle')
        [indmle, meamle] = tra2ind(curhmm(useiter).fitmle);
        stpsmle{i} = diff(meamle);
        dwlsmle{i} = diff(indmle) / 2500;
    end
end

figure, hist([stps{:}], 30)
if ~isempty([stpsmle{:}])
    figure, hist([stpsmle{:}],30)
end



