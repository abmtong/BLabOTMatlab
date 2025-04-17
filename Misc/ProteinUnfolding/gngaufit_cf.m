function gngaufit_cf(ngau)

%Runs ngaufit_cf but with ginput for guess
% Set the object as the gco and axis as gca (click the graph) and then run
ob = gco;

xx = ob.XData;
yy = ob.YData;

a = ginput(ngau);
ngaufit_cf(xx, yy, ngau, [], a(:,1));