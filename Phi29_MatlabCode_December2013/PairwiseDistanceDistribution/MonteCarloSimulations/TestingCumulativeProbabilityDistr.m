%%draw 100 random times
N=1000;
MeanT = 5;    
clear TimePool;
for i=1:N
    TimePool(i)=MonteCarlo_DrawRandomExponentialTime(MeanT);
end

%% Trials with resampling
Trials = 100;
figure; hold on;

for t = 1:Trials
    Duration = randsample(TimePool,length(TimePool),1); %draw, drawing the same value twice is ok
    Duration = sort(Duration);
    
    P = [];
    T = [];
    for i=1:length(Duration)
        P(i)=i/length(Duration);
        T(i)=Duration(i);
    end

    P = [0 P];
    T = [0 T];
    plot(T,P,'b');
    %axis([min(T) max(T) min(P) max(P)]);
end