function plotalldats()

p = uigetdir();

if ~p
    return
end

%get all .dats in the folder

dts = dir([p filesep '*.dat']);
dtssz = [dts.bytes];
dts = {dts.name};

%get all a*.dats
dtsa = dir([p filesep 'a*.dat']);
dtsa = {dtsa.name};
%remove leading a
dtsa = cellfun(@(x) x(2:end), dtsa, 'Uni', 0);

%process all cals
len = length(dtsa);
cals = cell(1, len);
if len == 0
    cal.AX.a = 1000;
    cal.AX.k = 0.3;
    cal.AX.mean = 0;
    cal.BX.a = 1000;
    cal.BX.k = 0.3;
    cal.BX.mean = 0;
    cals = {cal};
    warning('No cals in folder %s, using default 1000/.3', p)
end
for i = 1:len
    opts.ra = 500;
    opts.verbose = 0;
    tmp = processHiFreq([p filesep dtsa{i}]);
    cal.AX = Calibrate(tmp.AX, opts);
    cal.BX = Calibrate(tmp.BX, opts);
    cal.AX.mean = mean(tmp.AX);
    cal.BX.mean = mean(tmp.BX);
    cals{i} = cal;
end

%say 

%process remaining dats
len = length(dts);

f5 = @(x) windowFilter(@mean, x, [], 5);

lastcal = 1;
for i = 1:len
    %check if is cal, update 'latest cal'
    tf = find(strcmpi(dts{i}, dtsa), 1);
    if tf
        lastcal = tf;
        continue
    end
    %if starts with letter, skip
    if any(strcmpi(dts{i}(1), {'a' 'b' 'c' 'd' 'e' 'f' 'g'}));
        continue
    end
    
    %if small (<100kb) skip [e.g. an offset v2]
    if dtssz(i) < 1e5
        continue
    end
    
    %otherwise process as usual
    
    %find nearest cal
    cal = cals{lastcal};
    %load
    d = readDat([p filesep dts{i}]);
    %calc for, ext
    e = 760 * d(5,:) + (d(3,:)-cal.AX.mean) * cal.AX.a - (d(4,:)-cal.BX.mean) * cal.BX.a;
    f = ( (d(4,:)-cal.BX.mean) * cal.BX.a * cal.BX.k - (d(3,:)-cal.AX.mean) * cal.AX.a * cal.AX.k )/2;
    %convert to contour
    c = e ./ XWLC(max(f, 1));
    %filter and decimate by 5
    ef = f5(e);
    ff = f5(f);
    cf = f5(c);
    
    figure('Name', 
    subplot(2,2,1), plot(ef)
    subplot(2,2,2), plot(ff)
    subplot(2,2,[3 4]), plot(cf)
    
    
end








