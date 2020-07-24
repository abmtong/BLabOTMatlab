function FinalProbability = EstimateErrorMonteCarlo(Center,Sigma)
% Estimating the fraction of 2.5, 5, 7.5, and 10bp bursts prior to a pause
% cluster using a monte-carlo approach
Nsim = 1000;
Ndraw = length(Center); %how many times to draw in each simulation

FinalProbability = [];

for s=1:Nsim
    Grid = -10:0.1:25;
    Value = zeros(size(Grid));

    for d = 1:Ndraw
        i = randsample(length(Center),1);
        temp  = NormalizedGaussianRepresentation(Grid,Center(i),Sigma(i)); %the gaussian contribution of the current peak
        Value = Value + temp;
    end
    
    Grid = Grid*10/9;

    Limits{1}=[1.25 3.75];
    Limits{2}=[3.75 6.25];
    Limits{3}=[6.25 8.75];
    Limits{4}=[8.25 13];
    Limits{5}=[-1.25 1.25];
    
    for i = 1:length(Limits)
        Min = Limits{i}(1);
        Max = Limits{i}(2);
        Ind = Grid>Min & Grid<Max;
        Probability(i) = sum(Value(Ind));
    end
    Probability(4) = Probability(4)+Probability(5); %10bp and 0 bp come together
    Probability(5) = [];
    
    Probability = 100*Probability./sum(Probability); %this will be in percent
    FinalProbability = [FinalProbability; Probability]; %add current results to the list
    disp(num2str(s));
end
end