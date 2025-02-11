function out = procFran_cross(inst, inOpts)
%Fit crossing time to 1exp
% EH just use median

%Apply tfpick with ezFactPlot

%Create figure
figure
ax = gca;
hold on
ax.YScale = 'log';

roi = [558 704]-16;

len = length(inst);
outraw = zeros(len,4); %exp fit, median, N_reach, N_cross
for i = 1:len
    %Get data
    t = inst(i).tcr;
    t = t(~isnan(t));
    
    %Create graph
    nn = length(t);
    xx = sort(t);
    yy = (nn:-1:1)/nn;
    
%     %Fit, MLE -- doesn't fit well since it doesn't hit (0,0), so gamma? or 
%     [mu, ci] = expfit(t);

    %Fit, curve fitting, just tail size (i.e. non-1 y-intercept
    fitfcn = @(x0,x) x0(1)*exp(-x/x0(2));
    xg = [1 10];
    ft = lsqcurvefit(fitfcn, xg, xx, yy);
    mu = ft(2);
    ci = [0 0];
    
    %Calculate basic crossing stats
    nreach = sum( cellfun(@(x) any(x > roi(1)), inst(i).drA ) );
    ncross = length(t);
    
    %Save
    outraw(i,:) = [mu median(xx) nreach ncross];
    
    
    %Plot
    coi = ax.ColorOrderIndex;

    plot(xx,yy, 'o');
    ax.ColorOrderIndex = coi;
%     plot(xx, 1 - expcdf(xx, mu))
    plot(xx, fitfcn(ft ,xx));
    
end

ylim([1e-2 1])
xlim([0 200])

out = outraw;

lgnam = [{inst.nam} ; repmat({'Fit'}, 1, len)];

legend( lgnam(:)' )


