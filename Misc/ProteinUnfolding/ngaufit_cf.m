function [out, fh] = ngaufit_cf(xx, yy, ngau, ax, muguess)
%Curvefit a sum of N gaussians to plot(xx,yy)

    function out = fitfcn(x0, x)
        out = normpdf(x, x0(1), x0(2)) * x0(3);
        for ii = 2:ngau
            out = out + normpdf(x, x0( (ii-1)*3+1 ), x0( (ii-1)*3+2 )) * x0( (ii-1)*3+3 );
        end
    end

xx = double(xx);
yy = double(yy);

if nargin < 4 || isempty(ax)%Axis is not supplied, plot in new figure
    figure, ax=gca; hold on
end

%Plot underlying data
bar(ax, xx, yy, 'FaceColor', [.7 .7 .7], 'EdgeColor', 'none')

%If ngau == 0, just quit
if ngau == 0
    out = [];
    fh = [];
    return
end

%fit vector is [mean sd amp] ngau times
lb = repmat( [min(xx) 0 0], 1,ngau);
ub = repmat( [max(xx) inf inf], 1,ngau);
xg = [ linspace(xx(1), xx(end), ngau)  ;  (range(xx)/ngau/3) * ones(1,ngau) ; max(yy/2)*ones(1,ngau)];
if nargin >= 5 %Set a guess if supplied. Overwrite NANs with regular guess.
    xg( ~isnan(muguess) ) = muguess(~isnan(muguess));
end
% xg = reshape(xg, ngau, 3);
%Set height to actual height at guess
xg(3,:) = interp1(xx, yy, xg(1,:), 'linear', 0) ./ arrayfun(@(x) normpdf(0,0,x), xg(2,:));
xg = xg(:)';

optopts = optimoptions('lsqcurvefit', 'Display', 'off');
[out, ~, rsd, ~, ~, ~, jac] = lsqcurvefit(@fitfcn, xg, xx, yy, lb, ub, optopts);
fh = @fitfcn;
%Estimate error with @nlparci
oerr = nlparci(out, rsd, 'jacobian', jac);
%These are [lower, upper] CIs, convert to just error
oerr = oerr(:,2)' - out; %They're symmetric so just subtract from out

%Calculate area of each peak, should just be prefactor , out(3*i)

%There'll be some indicator text, let's plot this over each gaussian at the middle of ylim
ytxt = mean(ylim);
%Plot individual gaussians, with text label
for i = 1:ngau
    yy = normpdf(xx, out( (i-1)*3+1 ), out( (i-1)*3+2 )) * out( (i-1)*3+3 );
    plot(ax, xx, yy );
%     %Let's put the text in the middle of the gaussian. NO mimddle of ylim
%     maxy = max(yy);
    text(out( (i-1)*3+1 ), ytxt, sprintf('%0.2f\n±%0.2f\n%0.2fpts', out( (i-1)*3+1 ), oerr(i), out( (i-1)*3+3 )  ) , 'HorizontalAlignment', 'center')
end

%And sum of gaussians
plot(ax, xx, fitfcn(out, xx), 'k')
end

