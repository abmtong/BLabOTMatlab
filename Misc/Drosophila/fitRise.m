function inst = fitRise(inst)
%Fits output of ezSum_batch to {some shape} to get appearance time

opts.irng = [1 40]; %[80 120]; %X-range to fit to (get a bit before + a bit after the rise). Choose with e.g. ezSum_plot(inst) and pick a region around the rise
opts.fitmeth = 1; %Fit method, see code
opts.debug = 1; %Debug plot
opts.fil = 3; %Half-width of median filter (takes 2*fil+1 points)

len = length(inst);
outraw = cell(len,2); %Raw fits
out = zeros(len,2); %Appearance times of ch1 and ch2
for i = 1:len
    %Get data
    tmp1 = inst(i).vals1;
    tmp2 = inst(i).vals2;
    
    %Filter
    tmp1f = windowFilter(@median, tmp1, opts.fil, 1);
    tmp2f = windowFilter(@median, tmp2, opts.fil, 1);
    
    %Crop to irng
    tmp1c = tmp1( opts.irng(1):opts.irng(2) );
    tmp2c = tmp2( opts.irng(1):opts.irng(2) );
    tmp1fc = tmp1f( opts.irng(1):opts.irng(2) );
    tmp2fc = tmp2f( opts.irng(1):opts.irng(2) );
    
    
    %Fit to {something}
    
    switch opts.fitmeth
        case 1 %see @fitmeth1 below
            [out(i,1), outraw{i,1}] = fitmeth1( tmp1fc );
            [out(i,2), outraw{i,2}] = fitmeth1( tmp2fc );
            
    end
    
    %Add to inst
    inst(i).fr = out(i,:);
    inst(i).dt = out(i,1) - out(i,2);
    inst(i).frraw = outraw(i,:);
    inst(i).fropts = opts;
    
    %Debug plot: plot every fit
    if opts.debug
        if i == 1
            figure Name fitRise_Debug
            ax = gca;
            hold(ax, 'on')
        end
        

        %Squish these to [i, i+1], so get squish params
        minmax1 = [ min(tmp1c) max(tmp1c)-min(tmp1c)];
        minmax2 = [ min(tmp2c) max(tmp2c)-min(tmp2c)];
        
        %And plot: raw, filtered, fit
        plot(ax, i+ (tmp1c - minmax1(1)) / minmax1(2), 'Color', hsv2rgb( 1/3, .3, .8 ) )
        plot(ax, i+ (tmp1fc - minmax1(1)) / minmax1(2), 'Color', hsv2rgb( 1/3, 1, .5 ) )

        plot(ax, i+ (tmp2c - minmax2(1)) / minmax2(2), 'Color', hsv2rgb( 0, .3, .8 ) )
        plot(ax, i+ (tmp2fc - minmax2(1)) / minmax2(2), 'Color', hsv2rgb( 0, 1, .5 ) )

        %Dont plot if isnan (was skipped)
        if ~isnan(out(i,1))
            %Plot fit line
            plot(ax, i+ (outraw{i,1}{2} - minmax1(1)) / minmax1(2), 'Color', hsv2rgb( 1/3, 1, .3 ), 'LineWidth', 1 )
            %And a vertical line at the point
            plot(ax, (1+out(i,1)) * [1 1],  i+[0 1], 'Color', 'g')
        end
        if ~isnan(out(i,2))
            plot(ax, i+ (outraw{i,2}{2} - minmax2(1)) / minmax2(2), 'Color', hsv2rgb( 1, 1, .3 ), 'LineWidth', 1 )
            plot(ax, (1+out(i,2)) * [1 1],  i+[0 1], 'Color', 'r')
        end
        drawnow
        
    end
end


%Plot time delay histogram
dt = out(:,1) - out(:,2);
fitRise_plot(dt)


    function [o, or] = fitmeth1(yy)
        %Crop to maximum, or somewhere close to it
%         imax = find( yy > prctile(yy, 80), 1, 'first'); %To percentile
        imax = find( yy > ( min(yy)*.25 + max(yy)*0.75 ), 1, 'first'); %To percent of max <-probably best method
%         [~, imax] = max(yy);
        ypre = yy(1:imax);
        
        xx = (1:length(ypre));
        %Fit this to flat-rise?
        
        %I guess we can only really do this via loop?
        hei = length(ypre)-2; %Minus two since the linear bit must be at least 2 pts
        
        if hei < 1
            %Too noisy to find, skip
            o = nan;
            or = [];
            return
        end
        
        scrs = inf(1,hei);
        fits = cell(1,hei);
        oo = optimoptions('lsqcurvefit', 'Display', 'off');
        %Take every trial dividing point...
        for ii = 1:hei
            %Function is flat pre, linear post
            yflat = mean( ypre( 1:ii) );
            fitfcn = @(x0,x) yflat + x0 * x;
            ym = lsqcurvefit( fitfcn, (max(yy) - min(yy))/(length(yflat))  , xx( ii+1:end) -ii-1, ypre(ii+1:end), [], [],oo);
%             tmpfit = [ ii, yflat, polyfit( xx( ii+1:end ), ypre( ii+1:end ) , 1) ];
            tmpfit = {ii , yflat, ym, fitfcn}; %[step index, flat level, slope, fitfcn]
            %Create the fit line
%             fityy = [ tmpfit(2) * ones(1, ii) polyval( tmpfit(3:4), xx( ii+1:end ) ) ];
            fityy = [ tmpfit{2} * ones(1, ii) fitfcn( ym,  xx( ii+1:end) -ii-1 )];
            %Score is quadratic error between fit and data
            scrs(ii) = sum(  (ypre - fityy ).^2 );
            fits{ii} = {tmpfit fityy}; %Lets save both the fit params + curve
        end
        
        
        %Find winning score = minimum
        [~, minscr] = min(scrs);
        
        o = minscr;
        or = fits{minscr};
        
    end

end