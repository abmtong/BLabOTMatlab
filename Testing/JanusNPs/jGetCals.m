function [fc, D] = jGetCals(nn)
%Extracts powspec info [just the useful bits] from calibrations

[f, p] = uigetfile('cal*.mat', 'Mu', 'on');
if ~p
    return
end
if ~iscell(f)
    f = {f};
end


if nargin < 1
    nn = [];
end

%If nn is nonempty, use f as a base file name and construct the rest
if ~isempty(nn)
    nn = cellfun(@(x) textscan(x, '%d%s'), nn, 'Un', 0);
    ll = cellfun(@(x) x{2}, nn);
    nn = cellfun(@(x) x{1}, nn);
    mon = textscan(f{1}, 'cal%dN%d.mat');
    mon = mon{1};
    f = arrayfun(@(x) sprintf( sprintf('cal%06dN%%02d.mat', mon) , x ), nn, 'Un', 0);
else
    ll = repmat({'ab'}, [1 length(f)]);
end

len = length(f);
fc = nan(len,4);
D = nan(len,4);

for i = 1:len
    %Load
    sd = load(fullfile(p, f{i}));
    cal = sd.stepdata.cal;
    
    %Get info
    if any(ll{i} == 'a')
        if recal
            Guess = [1e3 
            lPbf = log(cal.AX.Pbf);
            fitfcn = @(x)(log(Lorentzian(x,Fbf,opts)) - lPbf);
            options = optimoptions(@lsqnonlin);
            options.Display = 'none';
            fit = lsqnonlin(fitfcn, Guess,lb,ub,options);
            
            
            cal.AX.fit = ;
            cal.AY.fit = ;
        end
        
        
        
        fc(i,1) = cal.AX.fit(1);
        fc(i,2) = cal.AY.fit(1);
        D(i,1)  = cal.AX.fit(2);
        D(i,2)  = cal.AY.fit(2);
    end
    if any(ll{i} == 'b')
        fc(i,3) = cal.BX.fit(1);
        fc(i,4) = cal.BY.fit(1);
        D(i,3)  = cal.BX.fit(2);
        D(i,4)  = cal.BY.fit(2);
    end
end








