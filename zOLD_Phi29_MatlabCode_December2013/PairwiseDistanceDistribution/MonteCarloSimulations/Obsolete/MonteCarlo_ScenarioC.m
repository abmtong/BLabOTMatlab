function [Nmin DwellTimes]=MonteCarlo_ScenarioC(AdpReleaseT,AtpBindingT,HydrolysisT,Nrounds,Alpha,PlotOption)
% This function simulates scenario C of ATP binding and ADP release (see
% Ghe's notebook #3, page 28, 8 Mar 2011). We start with a fully ATP loaded
% ring, hydrolyze them, release phosphate, translocate DNA. Then we are
% left with ADPs on the ring. At this point all ADPs have to be released in
% a coordinated fashion then the motor is empty and all ATPs have to bind
% in a coordinated fashion. We repeat this simulation Nrounds times and
% plot a histogram of the cycle duration (or dwell duration). Here we are
% assuming that the translocation step is really fast
%
% Alpha is a way to make the first ATP binding special, since the first
% subunit that will bind ATP will be in a special nearest-neighbor
% environment
%
% USE: [Nmin DwellTimes]=MonteCarlo_ScenarioC(AdpReleaseT,AtpBindingT,HydrolysisT,Nrounds,Alpha)
%      this will run it and generate the DwellTime histogram plot    
%
%      [Nmin DwellTimes]=MonteCarlo_ScenarioC(AdpReleaseT,AtpBindingT,HydrolysisT,Nrounds,Alpha'NoPlot')
%      this will run it and not generate any plots
%
% Gheorghe Chistol, 9 Mar 2011

if nargin==4
    PlotOption='Plot';
end

ActiveSubunits=4; %here we assume that only 4 subunits are active in one cycle, feel free to change this to 5

DwellTimes=[]; %initialize the vector that contains all dwell times
for r=1:Nrounds
    
    %start with fully ATP loaded motor
	%hydrolysis happens, maybe some other processes happen before translocation
    
    %now we have a ring loaded with ADP
    n=1; %start with the first subunit
    tempADP=[];
    tempATP=[];
    
    %deal with all ADP releases first
    while n<=ActiveSubunits 
        tempADP(end+1) = MonteCarlo_DrawRandomExponentialTime(AdpReleaseT); %release ADP
        n=n+1; %move on to the next subunit
    end

    %deal with all ATP binding next
    while n<=ActiveSubunits 
        if n==1
            tempATP(end+1) = MonteCarlo_DrawRandomExponentialTime(Alpha*AtpBindingT); %binding ATP
        else
            tempATP(end+1) = MonteCarlo_DrawRandomExponentialTime(AtpBindingT); %binding ATP
        end
        n=n+1; %move on to the next subunit
    end    
    DwellTimes(end+1)=sum(tempADP)+sum(tempATP)+HydrolysisT; %#ok<AGROW> %add the current dwell time to the list
end
Nmin=MonteCarlo_CalculateNmin(DwellTimes);
if strcmp(PlotOption,'Plot')
    figure;
    hist(DwellTimes,20);
    legend(['Nmin=' num2str(Nmin)]);
    xlabel('Dwell Time (arbitrary)');
    ylabel('Probability Density (arbitrary)')
    title(['<ADP Release T>=' num2str(AdpReleaseT) '; <ATP Binding T>=' num2str(AtpBindingT) '; <HydrolysisT>=' num2str(HydrolysisT) '; Nrounds=' num2str(Nrounds)]);
end