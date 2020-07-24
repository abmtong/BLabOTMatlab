function CurrentCycleT=MonteCarlo_ComplexScenarioA(AdpBindingT,AdpReleaseT,AtpLooseBindingT,AtpLooseReleaseT,AtpTightBindingT,HydrolysisT,Alpha)
% This is roughly the same as MonteCarlo_ScenarioA, except that here we
% model the ATP binding step as a LooseBinding/Unbinding followed by a
% irreversible tight binding. The LooseBinding rate depends proportionally
% on [ATP], while the LooseUnbinding and TightBinding rates are [ATP]
% independent. For now our simulations assume [ADP]=0;
%
% USE: T=MonteCarlo_ComplexScenarioA(AdpReleaseT,LooseAtpBindingT,LooseAtpUnbindingT,TightAtpBindingT,HydrolysisT,Alpha);        
%
% Gheorghe Chistol, 14 March 2011

ActiveSubunits = 4;
CurrentCycleT  = 0; %start with fully ATP loaded motor
CurrentCycleT  = CurrentCycleT+HydrolysisT; %hydrolysis happens, maybe some other processes happen before translocation

%now we have a ring loaded with ADP
n=1; %start with the first subunit
while n<=ActiveSubunits 
    
    if n==1 %the first subunit binding ATP is special
        temp = MonteCarlo_AdpReleaseAtpBinding(AdpReleaseT,AdpBindingT,Alpha*AtpLooseBindingT,AtpLooseReleaseT,AtpTightBindingT);
    else
        temp = MonteCarlo_AdpReleaseAtpBinding(AdpReleaseT,AdpBindingT,AtpLooseBindingT,AtpLooseReleaseT,AtpTightBindingT);
    end
    
    CurrentCycleT = CurrentCycleT+temp;
    n=n+1; %move on to the next subunit
end