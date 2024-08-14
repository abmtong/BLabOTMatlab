function [o or] = tmptester(yy)
        %Crop to maximum, or somewhere close to it
%         imax = find( yy > prctile(yy, 80), 1, 'first');
        imax = find( yy > ( min(yy)*.25 + max(yy)*0.75 ), 1, 'first'); %75% of range
%         [~, imax] = max(yy);
        ypre = yy(1:imax);
        
        
        xx = (1:length(ypre));
        %Fit this to flat-rise?
        
        %I guess we can only really do this via loop?
        hei = length(ypre)-2; %Minus two since the linear bit must be at least 2 pts
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
            tmpfit = {ii , yflat, ym, fitfcn};
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