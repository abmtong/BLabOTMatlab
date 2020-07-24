function [T,Nucleotide]=MonteCarlo_ADP_Empty_ATP_ADP(Tatp_off,Tatp_on,Tadp_off,Tadp_on,Tatp_tight)
% This function treats the ADP-release and ATP binding to an individual
% ATPase pocket in detail. 
%
% [D] <> [ ] <> [T] > [T*]
%
% The last state is tightly-bound ATP, irreversible. ADP binding rate is
% proportional to [ADP], while ADP release rate is constant. Similarly, ATP
% loose binding rate is proportional to [ATP], and the ATP loose release
% rate is constant. ATP tight binding is constant.
%
% If there is no ADP in solution, Tadp_on=NaN;
%
% USE: T=MonteCarlo_ADP_Empty_ATP_TightATP(Tatp_off,Tatp_on,Tadp_off,Tadp_on,Tatp_tight)
%
% Gheorghe Chistol, 02 Aug 2011

%% Start with a pocket that contains ADP.
T=0;
Status='ADP-Bound';
Nucleotide='ADP';
while ~strcmp(Status,'Completed');

    %% This is the probability to release ADP
    if strcmp(Status,'ADP-Bound')
        %see how long it takes to release the ADP
        T=T+exprnd(Tadp_off);
        Status='Empty'; %the pocket is now empty
        %display('Empty')
    end
       
    %% if the subunit is empty, it tries to loosely bind ATP or ADP
    if strcmp(Status,'Empty')
          
      %we have both ATP and ADP in solution, both can bind
            trial_AtpLooseBindingT   = exprnd(Tatp_on);   
            trial_AdpLooseBindingT = exprnd(Tadp_on);  
                
                if trial_AdpLooseBindingT < trial_AtpLooseBindingT
                   T=T+trial_AdpLooseBindingT;
                   Status='ADP-LooselyBound'; %the pocket has loosely bound ADP
                   %disp('ATPgS molecule');
                else
                   T=T+trial_AtpLooseBindingT;
                   Status='ATP-LooselyBound'; %the pocket has bound ATP
                   %disp('ATP molecule');
                end
    end          
    
     %% if the subunit has loosely bound ATP or ADP, it will try to
      % tightly bind ATP or release any nucleotide
      
    if strcmp(Status,'ATP-LooselyBound')   
         %now we have two options: either undergo tight binding, or release the ATP
            trial_NucleotideTightBindingT = exprnd(Tatp_tight);
            trial_NucleotideLooseReleaseT = exprnd(Tatp_off);
            if  trial_NucleotideTightBindingT < trial_NucleotideLooseReleaseT
                T=T+trial_NucleotideTightBindingT;
                Status = 'Completed'; %tight binding was accomplished, the binding cycle is completed
                Nucleotide = 'ATP';
                %disp('ATP Bound')
           else
                T=T+trial_NucleotideLooseReleaseT;
                Status = 'Empty'; %the pocket releases the loosely-bound ATP, is now empty
                %disp('ATP Empty')
            end
     elseif strcmp(Status,'ADP-LooselyBound')
        %disp('We entered ADP')
        %ADP can only be release, there is no such thing as tightly binding
        %
           % trial_NucleotideTightBindingTgS = exprnd(Tatpgs_tight);
            trial_NucleotideLooseReleaseADP = exprnd(Tadp_off);
          % if  trial_NucleotideTightBindingTgS < trial_NucleotideLooseReleaseTADP
            T=T+trial_NucleotideLooseReleaseADP;
            %    Status = 'Completed'; %tight binding was accomplished, the binding cycle is completed
              
                %disp('ATPgS Bound')
          % else
           %     T=T+trial_NucleotideLooseReleaseTgS;
            Status = 'Empty'; %the pocket releases the loosely-bound ATP, is now empty
                %disp('ATPgS Empty')
           %end
           % Nucleotide = 'ADP';
          
      end
        %if the ATP tight binding candidate time is shorter, tight binding
        %will occur
        
end

end