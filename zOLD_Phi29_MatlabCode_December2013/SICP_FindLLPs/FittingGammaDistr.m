figure; hold on;
plot(X{1},P{1},'k','LineWidth',2)

modelFun =  @(p,x) gampdf(x,p(1),p(2));
startingVals = [1 0.1];
coefEsts = nlinfit(double(X{1}), double(P{1}), modelFun, startingVals);
xgrid = linspace(0,1,100);
line(xgrid, modelFun(coefEsts, xgrid), 'Color','r');