function MonteCarlo_TestingAtpOnlyLooseTightBinding()
% This one uses MonteCarlo_LooseAndTightAtpBinding() and feeds it various
% rates to explore the possibilities
%
% Gheorghe Chistol, 14 March 2011
SimulationN=5000;
LooseUnbindingT=300;
TightBindingT=50;
LooseBindingConst=10*100; %LooseBindingT=LooseBindingConst/[ATP]
ATP=[1 5 10 25 50 100 250 500 1000];
MeanT=zeros(1,length(ATP)); %the mean ATP loading time
Nmin = zeros(1,length(ATP)); %the Nmin corresponding to that particular [ATP]

for a=1:length(ATP) %a is the ATP concentration index
    CurrATP=ATP(a);
    T=zeros(1,SimulationN); %create empty vector for storing values
    
    for s=1:SimulationN %s is the simulation number index
        LooseBindingT=LooseBindingConst/CurrATP; %calculate the loose ATP binding constant based on current ATP concentration
        T(s)=MonteCarlo_LooseAndTightAtpBinding(LooseBindingT,LooseUnbindingT,TightBindingT);        
    end
    
    MeanT(a)=mean(T);
    Nmin(a)=MonteCarlo_CalculateNmin(T);
end

close all;
figure; 
subplot(2,1,1);
plot(ATP,1./MeanT,'.'); set(gca,'XScale','log');
subplot(2,1,2);
plot(ATP,Nmin,'.'); set(gca,'XScale','log');