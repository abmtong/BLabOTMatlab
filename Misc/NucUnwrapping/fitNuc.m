function out = fitNuc(inst)
%Fit each trace separately

%Force bounds to remove the LF transition
% frng = [1 2.5 5 35]; %For Nuc
frng = [1 2 5 35]; %For Nuc F. Maybe should use the same values...
fil = 100;

debug = 1; %Debug flag

if debug
    figure Name Debug
    ax = gca;
end

len = length(inst);
for i = 1:len
    %Grab data and filter
    ext = double( windowFilter(@mean, inst(i).ext, [], fil) );
    frc = double( windowFilter(@mean, inst(i).frc, [], fil) );
    
    %Crop last point
    ext = ext(1:end-1);
    frc = frc(1:end-1);
    
    if isempty(ext)
        continue
    end
    
    %Crop around LF
    i1 = find(frc > frng(1), 1, 'first');
    i2 = find(frc < frng(2), 1, 'last');
    i3 = find(frc > frng(3), 1, 'first');
    i4 = find(frc < frng(4), 1, 'last');
    
    %Find HF in i3:i4. Let's assume it's a single point = make sure fil is large enough
    
    [~, mi] = max(diff( ext(i3:i4) ) );
    % Crop out a pt on each side of this diff, too
    i3b = (i3+mi-2);
    i4b = i3b+4;
    
    
    %Crop data
    xc = ext([i1:i2 i3:i3b i4b:i4]);
    fc = frc([i1:i2 i3:i3b i4b:i4]);
    sz1 = i2-i1+1;
    sz2 = i3b-i3+1;
    sz3 = i4-i4b+1;
    th1 = [zeros(1, sz1)  ones(1, sz2) zeros(1, sz3)];
    th2 = [zeros(1, sz1) zeros(1, sz2) ones(1, sz3)];
    
    
    %Create fit fcn, special for each
    fitfcn = @(x0, x) XWLC(x, x0(1),x0(2)).*(x0(3)+x0(4)*th1 + x0(5)*th2);
    xg = [50 400 ext(i2) 25 30  ]; %PL SM CL dCL1 dCL2
    lb = [0 0 0 0 0];
    ub = [100 1e4 1e3 1e2 1e2];
    opop = optimoptions('lsqcurvefit', 'Display', 'none');
    %Fit
    ft = lsqcurvefit(fitfcn, xg, fc, xc, lb, ub, opop);
    
    %Get average residual of each section
    rsd = (fitfcn(ft, fc) - xc).^2;
    res123 = [ mean( rsd( ~(th1|th2)) ) mean( rsd( th1 == 1) ) mean(rsd(th2 == 1) ) ];
    
    
    
    %Debug: Check fit
    if debug
        cla(ax)
        hold(ax, 'on')
        plot(ext, frc);
        plot( XWLC(frc, ft(1), ft(2) )* ft(3) , frc) 
        plot( XWLC(frc, ft(1), ft(2) )* (ft(3)+ft(4)) , frc) 
        plot( XWLC(frc, ft(1), ft(2) )* (ft(3)+ft(5)) , frc) 
        
        arrayfun(@(x) plot(x*[1 1], ylim), ext([i1 i2 i3 i3b i4b i4]))
        
        pause(.5)
    end
    
    %Save fit
    inst(i).xwlc = ft;
    inst(i).ftrsd = res123;
    inst(i).con = inst(i).ext ./ XWLC( inst(i).frc, ft(1), ft(2) );
end

out = inst;