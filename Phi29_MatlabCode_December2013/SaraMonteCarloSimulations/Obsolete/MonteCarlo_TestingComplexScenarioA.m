function [ATP ADP Nmin MeanT]=MonteCarlo_TestingComplexScenarioA()
% This is roughly the same as MonteCarlo_ScenarioA, except that here we
% model the ATP binding step as a LooseBinding/Unbinding followed by a
% irreversible tight binding. The LooseBinding rate depends proportionally
% on [ATP], while the LooseUnbinding and TightBinding rates are [ATP]
% independent. For now our simulations assume [ADP]=0;
%
%
% Gheorghe Chistol, 14 March 2011

SimulationN          = 5000;
AtpLooseReleaseT     = 200;
AtpTightBindingT     = 5;
AdpReleaseT          = 200;
HydrolysisT          = 5;
AtpLooseBindingConst = 50*100; %AtpLooseBindingT = AtpLooseBindingConst/[ATP]
AdpBindingConst      = 20*100; %AdpBindingT      = AdpBindingConst/[ADP] 

ATP   = [1 3 5 8 10 15 25 35 50 100 250 500 1e3 3e3 1e4];
%ATP   = [50];
%ADP   = [0 5 10 20 50 200];
ADP = 0;
MeanT = zeros(length(ADP),length(ATP));
Nmin  = zeros(length(ADP),length(ATP));
Alpha = 50;

for t=1:length(ATP) %t is the ATP concentration index
    CurrATP=ATP(t);
    disp(['ATP=' num2str(CurrATP) ]);
    for d=1:length(ADP) %d is the ADP concentration index
        
        
        CurrADP=ADP(d);
        disp(['... ADP=' num2str(CurrADP) ])
        T=zeros(1,SimulationN); %create empty vector for storing values

        for s=1:SimulationN %s is the simulation number index
            
            AtpLooseBindingT = AtpLooseBindingConst/CurrATP; %calculate the loose ATP binding time based on current ATP concentration
            
            if CurrADP==0
                AdpBindingT = NaN; %no ADP in the buffer
            else
                AdpBindingT = AdpBindingConst/CurrADP; %calculate the ADP binding time based on the current ADP concentration
            end
            
            T(s) = MonteCarlo_ComplexScenarioA(AdpBindingT,AdpReleaseT,AtpLooseBindingT,AtpLooseReleaseT,AtpTightBindingT,HydrolysisT,Alpha);
        end

        MeanT(d,t) = mean(T);
        Nmin(d,t)  = MonteCarlo_CalculateNmin(T);
    end
end