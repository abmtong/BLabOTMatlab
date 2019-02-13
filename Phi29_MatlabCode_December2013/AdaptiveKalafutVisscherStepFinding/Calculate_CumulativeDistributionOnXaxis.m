function [F,x] = Calculate_CumulativeDistributionOnXaxis(X,Y)
F=[];
x=[];

for i=1:length(X)
    F(i)=sum(Y(1:i));
    x(i)=X(i);
end


figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1);
box(axes1,'on');
hold(axes1,'all');

ylim([0,1]);
% Create plot
plot(x,F,'LineWidth',2);

% Create xlabel
xlabel('Dwell Duration (s)','FontSize',16);

% Create ylabel
ylabel('Cumulative Distribution (a.u.)','FontSize',16);


end