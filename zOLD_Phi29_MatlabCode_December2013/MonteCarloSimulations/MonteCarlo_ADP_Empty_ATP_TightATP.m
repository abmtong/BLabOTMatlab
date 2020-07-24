function T=MonteCarlo_ADP_Empty_ATP_TightATP(Tatp_off,Tatp_on,Tadp_off,Tadp_on,Tatp_tight)
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
while ~strcmp(Status,'Completed')
    if strcmp(Status,'ADP-Bound')
        %see how long it takes to release the ADP
        T=T+MonteCarlo_DrawRandomExponentialTime(Tadp_off);
        Status='Empty'; %the pocket is now empty
    end
    
    if strcmp(Status,'ATP-LooselyBound')
        %now we have two options: either undergo tight binding, or release the ATP
        trial_AtpTightBindingT = MonteCarlo_DrawRandomExponentialTime(Tatp_tight);
        trial_AtpLooseReleaseT = MonteCarlo_DrawRandomExponentialTime(Tatp_off);

        %if the ATP tight binding candidate time is shorter, tight binding will occur
        if trial_AtpTightBindingT < trial_AtpLooseReleaseT
            T=T+trial_AtpTightBindingT;
            Status = 'Completed'; %tight binding was accomplished, the binding cycle is completed
        else
            T=T+trial_AtpLooseReleaseT;
            Status = 'Empty'; %the pocket releases the loosely-bound ATP, is now empty
        end
    end
    
    if strcmp(Status,'Empty')
        if isnan(Tadp_on) 
            T = T+MonteCarlo_DrawRandomExponentialTime(Tatp_on);
            Status='ATP-LooselyBound'; %if we have no ADP in solution, only ATP can bind to the pocket
        else
            %we have both ATP and ADP in solution, both can bind
            trial_AdpBindingT      = MonteCarlo_DrawRandomExponentialTime(Tadp_on);
            trial_AtpLooseBindingT = MonteCarlo_DrawRandomExponentialTime(Tatp_on);

            if trial_AtpLooseBindingT < trial_AdpBindingT
                T=T+trial_AtpLooseBindingT;
                Status='ATP-LooselyBound'; %the pocket has loosely bound ATP
            else
                T=T+trial_AdpBindingT;
                Status='ADP-Bound'; %the pocket has bound ADP
            end
        end
    end
end