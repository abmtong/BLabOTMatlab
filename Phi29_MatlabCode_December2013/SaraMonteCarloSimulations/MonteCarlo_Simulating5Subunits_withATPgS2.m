function [ATPgsCounter DwellTimes]=MonteCarlo_Simulating5Subunits_withATPgS2(ATP,ATPgS,Tatp_on, Tatpgs_on,Tatp_off,Tatpgs_off,Tadp_on,Tadp_off,Tatp_tight,Tatpgs_tight,Tatpgs_tight_off,AlphaT,AlphaD,AlphaTb,Nrounds)
% This function generates the dwell-time distribution for the following
% model: The Cycle starts with 5 ADPs, the ADPs are released one by one
% with ATP binding and ADP release interlaced. Here we assume that
% hydrolysis and translocation are fast, so we don't worry about that.
%
% AlphaT - how much slower is the first subunit at ATP loose binding
% AlphaD - how much slower is the first subunit at ADP release
%
% USE: [Nmin DwellTimes]=MonteCarlo_Simulating5Subunits(Tatp_on,Tatp_off,Tadp_on,Tadp_off,Tatp_tight,AlphaT,AlphaD,Nrounds)
%
% Gheorghe Chistol, 02 Aug 2011

if nargin==4
    PlotOption='Plot';
end

ActiveSubunits=5; %here we assume that only 4 subunits are active in one cycle, feel free to change this to 5
%T = MonteCarlo_ADP_Empty_ATP_TightATP(Tatp_off,Tatp_on,Tadp_off,Tadp_on,Tatp_tight)
ATPgsCounter=0;
DwellTimes=[]; %initialize the vector that contains all dwell times
for r=1:Nrounds
    CurrentCycleT = 0; %start with fully ATP loaded motor    
    %now we have a ring loaded with ADP
    n=1; %start with the first subunit
    while n<=ActiveSubunits 
        %let all subunits release ADP then bind ATP one at a time
        if n==1 %the first subunit: ADP-release and ATP-binding are special 
            [temp,Nucleotide] = MonteCarlo_ADP_Empty_ATP_ATPgS_TightATP(ATP,ATPgS,Tatp_off,Tatpgs_off, AlphaT*Tatp_on,AlphaT*Tatpgs_on, AlphaD*Tadp_off,Tadp_on,AlphaTb*Tatp_tight,AlphaTb*Tatpgs_tight);
        elseif n==2
            [temp,Nucleotide] = MonteCarlo_ADP_Empty_ATP_ATPgS_TightATP(ATP,ATPgS,Tatp_off,Tatpgs_off,Tatp_on,Tatpgs_on,Tadp_off,Tadp_on,Tatp_tight,Tatpgs_tight);
        elseif n==3
            [temp,Nucleotide] = MonteCarlo_ADP_Empty_ATP_ATPgS_TightATP(ATP,ATPgS,Tatp_off,Tatpgs_off,Tatp_on,Tatpgs_on,Tadp_off,Tadp_on,Tatp_tight,Tatpgs_tight);
        elseif n==4
            [temp,Nucleotide] = MonteCarlo_ADP_Empty_ATP_ATPgS_TightATP(ATP,ATPgS,Tatp_off,Tatpgs_off,Tatp_on,Tatpgs_on,Tadp_off,Tadp_on,Tatp_tight,Tatpgs_tight);
        elseif n==5
            [temp,Nucleotide] = MonteCarlo_ADP_Empty_ATP_ATPgS_TightATP(ATP,ATPgS,Tatp_off,Tatpgs_off,Tatp_on,Tatpgs_on,Tadp_off,Tadp_on,Tatp_tight,Tatpgs_tight);
        end
        
        if strcmp(Nucleotide,'ATP')
            %disp('entered here')
            CurrentCycleT = CurrentCycleT+temp;
            n=n+1; %move on to the next subunit
        elseif strcmp(Nucleotide, 'ATPgs')
            %disp('The cycle was interrumpted')
            CurrentCycleT = CurrentCycleT+exprnd(Tatpgs_tight_off);
            n=1; %move on to the next subunit
            ATPgsCounter=ATPgsCounter+1;
            %disp('Marker')
        end
    end
    DwellTimes(end+1)=CurrentCycleT; %#ok<AGROW> %add the current dwell time to the list
end

%disp('NumberofPauses')
disp(ATPgsCounter)
%disp('Length')
%disp((Nrounds*10)/1000)
%disp('Pause Density = ')
%disp((ATPgsCounter/Nrounds*10)*10)
%disp('Pauses per kb')

%Nmin = CalculateNminConfInt(DwellTimes, 1000, 0.95);
end

% if strcmp(PlotOption,'Plot')
%     figure;
%     hist(DwellTimes,20);
%     legend(['Nmin=' num2str(Nmin)]);
%     xlabel('Dwell Time (arbitrary)');
%     ylabel('Probability Density (arbitrary)')
%     title(['<ADP Release T>=' num2str(AdpReleaseT) '; <ATP Binding T>=' num2str(AtpBindingT) '; Nrounds=' num2str(Nrounds)]);
% end