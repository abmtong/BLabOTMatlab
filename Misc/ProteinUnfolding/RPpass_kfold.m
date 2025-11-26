function out = RPpass_kfold(inst)

%Get kfold from RPpass data struct
len = length(inst);
outraw = cell(1,len);
Fs=25e3;
kT = 4.1;
pPL=0.6;
verbose = 0;

if verbose
    figure Name RPpass_kfold_verbose
    ax = gca;
    hold on
end
for i = 1:len
    tmp = inst(i);
    %Reconstruct state vector from tmp.rips ...? or just calc directly
    dw = diff( [1 tmp.rips(:,1)'] );
    typ = tmp.rips(:,4)';

    %Un/folding transitions / attempts are 0,1
    tfol = dw(typ == 0 | typ == 1) / Fs;
    tunf = dw(typ == 2 | typ == 3) / Fs;
    
    %Un/folding force is already calc'd
    ffol = tmp.folfrc(2);
    funf = tmp.folfrc(1);
    
    %Fit the times to exp
    ftfol = 1/mle(tfol, 'distribution', 'exp'); %mle returns exp(-t/tau), change to exp(-kx)
    ftunf = 1/mle(tunf, 'distribution', 'exp');

    %Also fit with fitnexp_hybrid
    fnehf = fitnexp_hybridV2(tfol, struct('verbose', 0));
    fnehu = fitnexp_hybridV2(tunf, struct('verbose', 0));
    
    %Plot if verbose
    if verbose
        ccdf = @(x) plot(ax, sort(x) , (length(x):-1:1)/length(x) );
        plx = @(x,k) plot( sort(x), exp(-k*sort(x)), '--' );
        cla(ax)
        ccdf(tfol);
        ccdf(tunf);
        plx(tfol, ftfol);
        plx(tunf, ftunf);
        legend({'Folding times' 'Unfolding times' 'Folding Fit' 'Unfolding Fit'})
        pause(1)
    end

    
    %Save, hope it is ok. Don't append to make this a light file
    tout = [];
    tout.tfol = tfol;
    tout.tunf = tunf;
    tout.ffol = ffol;
    tout.funf = funf;
    tout.ftfol = ftfol;
    tout.ftunf = ftunf;
    tout.fnehf = fnehf; %This is a1, k1, a2, k2, ...
    tout.fnehu = fnehu;
    outraw{i} = tout;

    % tmp.rips  = [ 'middle', left edge, right edge, type ];
    %  type = [0, 1, 2, 3] == [U>U, U>F, F>U, F>F]
end
out = [outraw{:}];
% Move this to another function

%Method 1: plot ln k vs F, lets do like N = marker size or something, then fit delta
figure Name RPpass_kfold
hold on
ax=gca;
% ccdf = @(x) plot(ax, sort(x) , (length(x):-1:1)/length(x) );
% plx = @(x,k) plot( sort(x), exp(-k*sort(x)), '--' );
fittype = 3;
switch fittype
    case 1 %MLE
        lkf = log( [out.ftfol]);
        lku = log( [out.ftunf]);
    case 2 %fitnexp_hybridV2
        lkf = log( cellfun(@(x) x(2), {out.fnehf}) );
        lku = log( cellfun(@(x) x(2), {out.fnehu}) );
    case 3 %Bin by force, then MLE ?
        fbinsz = 0.2;
        tmin = 00; %Minimum... 10ms?
        %Discretize force
        foln = floor([out.ffol] / fbinsz);
        unfn = floor([out.funf] / fbinsz);
        %Bin events together
        maxi = max( [ foln(:)' unfn(:)' ] );
        lkf = nan(1,maxi);
        lku = nan(1,maxi);
        lkfe = nan(1,maxi);
        lkue = nan(1,maxi);
        ff = (0:maxi-1)*fbinsz + fbinsz/2;
        for i = 1:maxi
            ki = foln == i;
            if any(ki)
                %Group
                dat = [out(ki).tfol];
                dat = dat(dat>tmin);
                %MLE
                [k, kci] = mle(dat, 'distribution', 'exp');
%                 ftfol = 1/k; 
                %Save
                lkf(i) = log(1/k);
                lkfe(i) = max(abs( log(k./kci)) );
            end
            ki = unfn == i; %Do unf later
            if any(ki)
                %Group
                dat = [out(ki).tunf];
                dat = dat(dat>tmin);
                %MLE
                [k, kci] = mle(dat, 'distribution', 'exp'); 
                %Save
                lku(i) = log(1/k);
                lkue(i) = max(abs(log(k./kci)));
                
            end
        end
        
        %Eh do all plotting here, as it's different
        figure, hold on
        fff = double(ff(~isnan(lkf)));
        ffu = double(ff(~isnan(lku)));
        lkfe = lkfe(~isnan(lkf));
        lkue = lkue(~isnan(lku));
        lkf = lkf(~isnan(lkf));
        lku = lku(~isnan(lku));
        
        errorbar(fff, lkf, lkfe)
        errorbar(ffu, lku, lkue)
        set(gca, 'ColorOrderIndex', 1)
        
        %Fit to k = k0 exp( F d XWLC(F) / kT ) ; ln(k) = ln(k0) + F d XWLC(F)/kT
        % Folding, -Fd/kT
        fitfcnf = @(x0,x, xxw) x0(1) - x * x0(2) .* xxw / kT;
        opop = optimoptions('lsqnonlin', 'Display', 'none');
        xg = [1 1]; %Eh whatever guess
        lb = [-inf 0];
        ub = [inf inf];
        fffxw = XWLC(fff, pPL, inf, kT);
        pff = lsqnonlin(@(x) fitfcnf(x, fff, fffxw) - lkf, xg, lb, ub, opop);
        % Unfolding, +Fd/kT
        fitfcnu = @(x0,x, xxw) x0(1) + x * x0(2) .* xxw / kT;
        ffuxw= XWLC(ffu, pPL, inf, kT);
        pfu = lsqnonlin(@(x) fitfcnu(x, ffu, ffuxw) - lku, xg, lb, ub, opop);
        
%         pff = polyfit(fff,lkf,1);
%         pfu = polyfit(ffu, lku, 1);
%         plot(fff, polyval(pff, fff), ':')
%         plot(ffu, polyval(pfu, ffu), ':')
        plot(fff, fitfcnf(pff, fff, fffxw))
        plot(ffu, fitfcnu(pfu, ffu, ffuxw))
        
        fprintf('%0.3f\n', [pff(1)*kT pff(2)])
        fprintf('%0.3f\n', [pfu(1)*kT pfu(2)])
        
        ftlgn = { sprintf('F Fit, \\delta=%0.2fnm', pff(2))...
            sprintf('U Fit, \\delta=%0.2fnm',  pfu(2)) };
        
        xlabel('Force (pN)')
        ylabel('ln(k) (ln(1/s))')
        legend([{'Folding' 'Unfolding' } ftlgn])

        
        return
end

ff = [out.ffol];
fu = [out.funf];
nf = cellfun(@length, {out.tfol});
nu = cellfun(@length, {out.tunf});

scatter(ff, lkf, nf)
scatter(fu, lku, nu)

%Curve fit, weight by n_obs per k. Do this by replicating each value by n
repval = @(k,n) arrayfun(@(x,y) repmat(x,1,y), k,n,'Un',0);
linkf = repval(lkf, nf);
linkf = [linkf{:}];
linff = repval(ff, nf);
linff = [linff{:}];

linku = repval(lku, nf);
linku = [linku{:}];
linfu = repval(fu, nf);
linfu = [linfu{:}];

linftf = polyfit(linff, linkf, 1);
linftu = polyfit(linfu, linku, 1);

%Plot fit
ax.ColorOrderIndex = 1;
plot( [min(ff) max(ff)] , polyval( linftf, [min(ff) max(ff)] ), '--' )
plot( [min(fu) max(fu)] , polyval( linftu, [min(fu) max(fu)] ), '--' )

nmperaa = 0.35;
aapl = 0.65;
%Create legend with dx in it
ftlgn = { sprintf('F Fit, \\delta=%0.2fnm (~%0.0f aa)', -linftf(1)*kT, -linftf(1)*kT / nmperaa / XWLC(median(linff), aapl, inf))  ...
          sprintf('U Fit, \\delta=%0.2fnm (~%0.0f aa)',  linftu(1)*kT,  linftu(1)*kT / nmperaa / XWLC(median(linff), aapl, inf)) };

xlabel('Force (pN)')
ylabel('ln(k) (ln(1/s))')
legend([{'Folding' 'Unfolding' } ftlgn])


%Should also try method 2: Bin events by force snippets

