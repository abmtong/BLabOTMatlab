function CurrentT=MonteCarlo_ComplexScenarioB(AdpBindingT,AdpReleaseT,AtpLooseBindingT,AtpLooseReleaseT,AtpTightBindingT,HydrolysisT,Alpha)
% Very similar to MonteCarlo_ScenarioB
%
% Gheorghe Chistol, 14 Mar 2011

ActiveSubunits=4; %here we assume that only 4 subunits are active in one cycle, feel free to change this to 5

%now we have a ring loaded with ADP
n=1; %start with the first subunit

IndividualSubunitT=zeros(1,ActiveSubunits); %each subunit will take some time to unbind the ADP and bind ATP

while n<=ActiveSubunits 
    %let all subunits release ADP then bind ATP one at a time
    if n==1 %the first subunit binding ATP is special
        temp=MonteCarlo_AdpReleaseAtpBinding(AdpReleaseT,AdpBindingT,Alpha*AtpLooseBindingT,AtpLooseReleaseT,AtpTightBindingT);
    else
        temp=MonteCarlo_AdpReleaseAtpBinding(AdpReleaseT,AdpBindingT,AtpLooseBindingT,AtpLooseReleaseT,AtpTightBindingT);
    end

    IndividualSubunitT(n) = HydrolysisT+temp;
    n=n+1; %move on to the next subunit
end

LongestTimeInd = find(IndividualSubunitT==max(IndividualSubunitT),1,'first');
CurrentT       = IndividualSubunitT(LongestTimeInd); %#ok<AGROW> %add the current dwell time to the list
