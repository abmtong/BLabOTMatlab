for i=1:20
    x=ATP;
    y=Vel(:,i);
    
    y_weight=Vel(:,i)./Err(:,i);
    if y_weight(1)==0 || isnan(y_weight(1))
        y_weight=ones(size(y));%in case we don't have a good estimate of errors
    end
    %y_weight=ones(size(y));
    fit=FitVelocityDataToHillEquation_14Dec10(x,y,y_weight);
    close gcf;
    ConfInt  = confint(fit,0.68);
    CoeffVal = coeffvalues(fit);
    Km(i)   = CoeffVal(1);
    Vmax(i) = CoeffVal(2);
    Km_UpperErr(i) = ConfInt(2,1)-Km(i);
    Km_LowerErr(i) = ConfInt(1,1)-Km(i);
    Vmax_UpperErr(i) = ConfInt(2,2)-Vmax(i);
    Vmax_LowerErr(i) = ConfInt(1,2)-Vmax(i);
end
%%
%figure; hold on;
errorbar(Filling,Km,Km_LowerErr,Km_UpperErr,'.b');
axis([10 20 0 40]);
xlabel('Capsid Filling (kb)');
ylabel('Km (uM)');
title('F6F7 vs WT, 68% Confidence Interval');

%%
%figure; hold on;
errorbar(Filling,Vmax,Vmax_LowerErr,Vmax_UpperErr,'.b');
axis([10 20 0 100]);
xlabel('Capsid Filling (kb)');
ylabel('Vmax (bp/sec)');
title('WT (black) vs F6F7 (blue), from Hill Plot Fits, 68% Confidence Interval');

