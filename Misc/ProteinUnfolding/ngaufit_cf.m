function [out, fh] = ngaufit_cf(xx, yy, ngau)
%Curvefit a sum of N gaussians to plot(xx,yy)

    function out = fitfcn(x0, x)
        out = normpdf(x, x0(1), x0(2)) * x0(3);
        for ii = 2:ngau
            out = out + normpdf(x, x0( (ii-1)*3+1 ), x0( (ii-1)*3+2 )) * x0( (ii-1)*3+3 );
        end
    end

xx = double(xx);
yy = double(yy);

%fit vector is [mean sd amp] ngau times
lb = zeros(1,3*ngau);
ub = repmat( [max(xx) 10 1], 1,ngau);
xg = [ linspace(xx(1), xx(end), ngau)'  ; 5* ones(ngau,1) ; ones(ngau,1)]';
xg = xg(:)';

optopts = optimoptions('lsqcurvefit', 'Display', 'off');
out = lsqcurvefit(@fitfcn, xg, xx, yy, lb, ub, optopts);
fh = @fitfcn;

figure, plot(xx, yy), hold on, plot( xx, fitfcn(out, xx));
for i = 1:ngau
    %Plot individual gaussians
    plot(xx, normpdf(xx, out( (i-1)*3+1 ), out( (i-1)*3+2 )) * out( (i-1)*3+3 ) );
    
end

end

