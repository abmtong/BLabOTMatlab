function inst = fitRise_p2(inst, inOpts)
%Part two: adjusts for background correction. Input: output of fitRise
% Generally not used rn

opts.backind = [120 200]; %Choose a region to sample background from.
opts.backmeth = 1; %Method to get background

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Make sure backind is within range
opts.backind = min( opts.backind, length(inst(1).vals1 ) );

len = length(inst);
out = nan(len,2);
for i = 1:len
    
    %FIRST check if this p1outraw is empty, = skipped by fitRise
    if isempty(inst(i).frraw{1}) || isempty(inst(i).frraw{2})
        continue
    end
    
    %Get data
    dat1 = inst(i).vals1( opts.backind(1):opts.backind(2) );
    dat2 = inst(i).vals1( opts.backind(1):opts.backind(2) );
    
    %Take background by <method>
    
    switch opts.backmeth
        case 1 %Median
            bkg1 = median(dat1);
            bkg2 = median(dat2);
            
    end
    
    %Recalc time by interpolating the line
    
    %The line is stored in p1outraw{i,1/2}{1}, with values [t0, bkg_old, slope, fcn]
    ft1 = inst(i).frraw{1}{1};
    ft2 = inst(i).frraw{2}{1};
    
    %So we want the intercept of the line that intercepts (t0, bkg_old) with the line y = new_background
    tnew1 = -( ft1{2} - bkg1 ) / ft1{3} + ft1{1};
    tnew2 = -( ft2{2} - bkg2 ) / ft2{3} + ft2{1};
    
    %And save
    out(i,:) = [tnew1 tnew2];
    
    %Add to inst
    inst(i).fr2 = out(i,:);
    inst(i).dt2 = out(i,1) - out(i,2);
    inst(i).fr2opts = opts;
end

%Plot
dt = out(:,1) - out(:,2);
fitRise_plot(dt)



