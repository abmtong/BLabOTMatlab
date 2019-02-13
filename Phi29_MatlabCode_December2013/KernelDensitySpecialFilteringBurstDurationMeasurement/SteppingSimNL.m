

%% Long Dwell

DwellRoll=exprnd(200, [5,1]);
dwell_1=round(sum(DwellRoll));

time=dwell_1/2500;
timespan=[0:(time/dwell_1):time];

x=timespan';
y=zeros(dwell_1,1);
y(:)=1000;


ynoise=y+2*randn(dwell_1,1);
ynoise(end+1)=1000+2*randn;

y(end+1)=1000;



