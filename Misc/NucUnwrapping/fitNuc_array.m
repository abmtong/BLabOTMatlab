function out = fitNuc_array(inst)
%Fit each trace separately

%Force bounds to remove the LF transition
% frng = [1 2.5 5 35]; %For Nuc
% frng = [1 2 5 35]; %For Nuc F. Maybe should use the same values...
frng = [1 2.75 7 50]; %4-Arrays
% frng = [1 1.5 5 50]; %FOX?
fil = 100;

%Calculate low force force by averging over 

lfwidmult = 0.7; %Calculate low force force by getting the force at con range between pre-LF and post-LF * this amt
lfwidmin = 7; % Use this minimum con range

maxtrns = 14; %Max transitions for HF fitting, i.e. 4 for tetranuc, 3 for tri, etc.
debug = 0; %Debug flag

if debug
    figure Name Debug
    ax = gca;
end

len = length(inst);
for i = 1:len
    %Grab data and filter
    ext = double( windowFilter(@mean, inst(i).ext, [], fil) );
    frc = double( windowFilter(@mean, inst(i).frc, [], fil) );
    
%     ext = double( windowFilter(@mean, inst(i).ext, fil/2, 1) );
%     frc = double( windowFilter(@mean, inst(i).frc, fil/2, 1) );
    
    %Crop last point
    ext = ext(1:end-1);
    frc = frc(1:end-1);
    
    if isempty(ext)
        continue
    end
    
    %Crop around LF
    i1 = find(frc > frng(1), 1, 'first');
    i2 = find(frc > frng(2), 1, 'first');
    i3 = find(frc > frng(3), 1, 'first');
    i4 = find(frc < frng(4), 1, 'last');
    
    %Find HF in i3:i4. Let's assume it's a single point = make sure fil is large enough
    
%     maxtrns = 4;
    [s, si] = sort( diff( ext(i3:i4) ) , 'descend');
    mi = si(1:maxtrns);
    i3b = min(mi) + i3 - 2;
    i4b = max(mi) + i3 +2;
    
    hfind = sort(mi) + i3 -1;
    [hfs, hfsi] = arrayfun(@(x) max(frc( x-2:x+2)), hfind);
    hfx = ext(hfsi+hfind-1-2);
    
%     ffind = frc(hfind - 2);
    
%     [~, mi] = max(diff( ext(i3:i4) ) );
%     % Crop out a pt on each side of this diff, too
%     i3b = (i3+mi-2);
%     i4b = i3b+4;
    
    
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
    ub = [500 1e4 1e4 1e3 1e3];
    opop = optimoptions('lsqcurvefit', 'Display', 'none');
    %Fit
    ft = lsqcurvefit(fitfcn, xg, fc, xc, lb, ub, opop);
    
    %Get average residual of each section
    rsd = (fitfcn(ft, fc) - xc).^2;
    res123 = [ mean( rsd( ~(th1|th2)) ) mean( rsd( th1 == 1) ) mean(rsd(th2 == 1) ) ];
    
    
    %Calculate low force force
    %Convert to contour
    con = ext ./ XWLC(frc, ft(1), ft(2));
    %Crop contour range
    lfwid = max(lfwidmin, ft(4)/2*lfwidmult);
    conrng = ft(3) + ft(4)/2 + [-lfwid lfwid];
    ki = con > conrng(1) & con < conrng(2);
    % Take longest segment in this range
    [in, me] = tra2ind(double(ki));
    dw = diff(in);
    ime = find(me == 1);
    dw = dw(me == 1);
    [~, ind] = max(dw);
    lfrng = [in(ime(ind)) in(ime(ind)+1)];
    lf = median(frc( lfrng(1):lfrng(2) ) );
    
    %Debug: Check fit
    if debug
        cla(ax)
        hold(ax, 'on')
        plot(ext, frc);
        plot( XWLC(frc, ft(1), ft(2) )* ft(3) , frc) 
        plot( XWLC(frc, ft(1), ft(2) )* (ft(3)+ft(4)) , frc) 
        plot( XWLC(frc, ft(1), ft(2) )* (ft(3)+ft(5)) , frc) 
        yl = ylim;
        arrayfun(@(x,y) plot(x*[1 1], [0 y]), ext([i1 i2 i3 i3b i4b i4]) , [frng(1) frng(2) frng(3) frng(4) frng(4) yl(2) ]  )
        
        pause(.5)
    end
    
    %Save fit
    inst(i).xwlc = ft;
    inst(i).ftrsd = res123;
    inst(i).con = inst(i).ext ./ XWLC( inst(i).frc, ft(1), ft(2) );
    inst(i).lff = lf;
    inst(i).hfs = hfs;
    inst(i).hfx = hfx;
    inst(i).hfind = hfind * fil;
    inst(i).fitii = [i1 i2 i3 i3b i4b i4]*fil;
end

out = inst;