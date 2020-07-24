function Results=MonteCarlo_ScenarioTesting()
Ratio=[1e-3 3e-3 1e-2 3e-2 1e-1 3e-1 1 3 1e1 3e1 1e2 3e2 1e3 3e3 1e4];

%the Ratio is the T_ADP_Release/T_ATP_Binding
% we are looking at very slow atp binding up to very fast ATP binding

AdpReleaseT = 100;
AtpBindingT = AdpReleaseT./Ratio;
HydrolysisT = 1; %nominal for now, almost negligible
Alpha = [0.001 1 5 10 20 50]; %the slow-down factor for the first ATP binding
Nrounds = 1000;
Ntrials  = 3; %Repeat each simulation this many times, to get a good error bar
Results=[];

%Results(a).Ratio vector
%Results(a).Nmin vector
%Results(a).NminStd
%Results(a).Alpha scalar value

for a=1:length(Alpha)
    %a
    %run through all Alpha Values
    Results(a).Alpha     = Alpha(a);
    Results(a).Ratio     = [];
    Results(a).Nmin      = [];
    Results(a).NminStd   = [];
    Results(a).NminStErr = [];
    
    for r=1:length(Ratio)
        %r
        temp=[]; %this holds the Nmin results of simulation trials under current conditions
        for t=1:Ntrials %t is the trial index
            %t
            %repeat the same simulation a bunch of times to get an error-bar
            [temp(end+1) ~]=MonteCarlo_ScenarioA(AdpReleaseT,AtpBindingT(r),HydrolysisT,Nrounds,Alpha(a),'NoPlot');
        end
        Results(a).Ratio(r)     = Ratio(r);
        Results(a).Nmin(r)      = mean(temp);
        Results(a).NminStd(r)   = std(temp);
        Results(a).NminStErr(r) = std(temp)/sqrt(Ntrials);
    end
    
end

figure; hold on;
%plot the results
PlotCode={'k','b','g',':k',':b',':g'};
for i=1:length(Results)
    %errorbar(Results(i).Ratio,Results(i).Nmin,Results(i).NminStErr,PlotCode{i});
    plot(Results(i).Ratio,Results(i).Nmin,PlotCode{i});
end
set(gca,'XScale','log');
xlabel('<ADP Release Time>/<ATP Binding Time>');
ylabel('Nmin');
title('Scenario A');
legend('{\alpha}=0.001','{\alpha}=1','{\alpha}=5','{\alpha}=10','{\alpha}=20','{\alpha}=50');