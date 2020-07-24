function [Nmin DwellTimes]=MonteCarlo_ScenarioA(AdpReleaseT,AtpBindingT,HydrolysisT,Nrounds,Alpha,PlotOption)
% This function simulates scenario A of ATP binding and ADP release (see
% Ghe's notebook #3, page 28, 8 Mar 2011). We start with a fully ATP loaded
% ring, hydrolyze them, release phosphate, translocate DNA. Then we are
% left with ADPs on the ring. At that point we release ADP then bind ATP
% one subunit at a time. This is counted in the CycleT (duration of the
% motor cycle). We repeat this simulation Nrounds times and plot a
% histogram of the cycle duration (or dwell duration). Here we are assuming
% that the translocation step is really fast
%
% Alpha is a way to make the first ATP binding special, since the first
% subunit that will bind ATP will be in a special nearest-neighbor
% environment
%
% USE: [Nmin DwellTimes]=MonteCarlo_ScenarioA(AdpReleaseT,AtpBindingT,HydrolysisT,Nrounds,Alpha)
%       this will generate a plot
%
%      [Nmin DwellTimes]=MonteCarlo_ScenarioA(AdpReleaseT,AtpBindingT,HydrolysisT,Nrounds,Alpha,'NoPlot')
%       this will not generate a plot
%
% Gheorghe Chistol, 9 Mar 2011

if nargin==5
    PlotOption='Plot';
end

ActiveSubunits=4; %here we assume that only 4 subunits are active in one cycle, feel free to change this to 5

DwellTimes=[]; %initialize the vector that contains all dwell times
for r=1:Nrounds
    
    CurrentCycleT = 0; %start with fully ATP loaded motor
    CurrentCycleT = CurrentCycleT+HydrolysisT; %hydrolysis happens, maybe some other processes happen before translocation
    
    %now we have a ring loaded with ADP
    n=1; %start with the first subunit
    while n<=ActiveSubunits 
        %let all subunits release ADP then bind ATP one at a time
        tempADP = MonteCarlo_DrawRandomExponentialTime(AdpReleaseT); %release ADP
        if n==1 %the first subunit binding ATP is special
            tempATP = MonteCarlo_DrawRandomExponentialTime(Alpha*AtpBindingT); %bind ATP
        else
            tempATP = MonteCarlo_DrawRandomExponentialTime(AtpBindingT); %bind ATP
        end
        CurrentCycleT = CurrentCycleT+tempADP+tempATP;
        n=n+1; %move on to the next subunit
    end
    DwellTimes(end+1)=CurrentCycleT; %#ok<AGROW> %add the current dwell time to the list
end

Nmin=MonteCarlo_CalculateNmin(DwellTimes);

if strcmp(PlotOption,'Plot')
    figure;
    hist(DwellTimes,20);
    legend(['Nmin=' num2str(Nmin)]);
    xlabel('Scenario B Dwell Time (arbitrary)');
    ylabel('Probability Density (arbitrary)')
    title(['<ADP Release T>=' num2str(AdpReleaseT) '; <ATP Binding T>=' num2str(AtpBindingT) '; <HydrolysisT>=' num2str(HydrolysisT) '; Nrounds=' num2str(Nrounds)]);
end