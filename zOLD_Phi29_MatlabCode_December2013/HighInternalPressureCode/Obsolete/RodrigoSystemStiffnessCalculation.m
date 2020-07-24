%drag the mat file into matlab, use rawall from here
t=rawall.time;
x=rawall.extension; %total extension
f=rawall.force; %total force;

%filter the t,x,f down to 10Hz
FilterFactor=round(2000/10); %filtering factor
T=FilterAndDecimate(t,FilterFactor);
X=FilterAndDecimate(x,FilterFactor);
F=FilterAndDecimate(f,FilterFactor);

XLim=[30 45];
TT = (T(1:end-1)+T(2:end))/2; %time vector for the stiffness calculation
KK = diff(F)./diff(X); %stiffness vector calculated from filtered data

IndKeep= TT<XLim(2) & TT>XLim(1);
TT=TT(IndKeep);
KK=KK(IndKeep);

%do the fitting with CFTOOL, it deals with outliers better
p=polyfit(TT,KK,1); %fit a first order polynomial to TT,KK
FitKK=polyval(p,TT); %straight line fit

figure; 
plot(T,F);
set(gca,'XLim',XLim);

figure; 
plot(TT,KK,'.b',TT,FitKK,'k-');
set(gca,'XLim',XLim);
