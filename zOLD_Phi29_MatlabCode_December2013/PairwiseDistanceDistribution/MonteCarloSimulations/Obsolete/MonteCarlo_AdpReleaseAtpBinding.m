function T=MonteCarlo_AdpReleaseAtpBinding(AdpReleaseT,AdpBindingT,AtpLooseBindingT,AtpLooseReleaseT,AtpTightBindingT)
% This function treats the ADP-release and ATP binding to an individual
% ATPase pocket in detail. 
%
% [D] <> [ ] <> [T] > [T*]
%
% The last state is tightly-bound ATP, irreversible. ADP binding rate is
% proportional to [ADP], while ADP release rate is constant. Similarly, ATP
% loose binding rate is proportional to [ATP], and the ATP loose release
% rate is constant. ATP tight binding is constant is usually quite a bit
% faster than the other rates.
%
% USE: T=MonteCarlo_AdpReleaseAtpBinding(AdpReleaseT,AdpBindingT,AtpLooseBindingT,AtpLooseReleaseT,AtpTightBindingT)
%
% Gheorghe Chistol, 14 March 2011

%% Start with a pocket that contains ADP.
T=0;
Status='ADP-Bound';
%disp(Status);
while ~strcmp(Status,'Completed') %as long as the status is not 'Completed'

    if strcmp(Status,'ADP-Bound') %if the pocket is ADP-bound
        %see how long it takes to release the ADP
        t=MonteCarlo_DrawRandomExponentialTime(AdpReleaseT);
        T=T+t;
        Status='Empty'; %the pocket is now empty
        %disp(Status);
    end
    
    if strcmp(Status,'ATP-LooselyBound') %if the pocket has bound ATP loosely
        %now we have two options: either undergo tight binding, or release the ATP
        trial_AtpTightBindingT = MonteCarlo_DrawRandomExponentialTime(AtpTightBindingT);
        trial_AtpLooseReleaseT = MonteCarlo_DrawRandomExponentialTime(AtpLooseReleaseT);

        %if the ATP tight binding candidate time is shorter, tight binding will occur
        if trial_AtpTightBindingT < trial_AtpLooseReleaseT
            %tight binding was accomplished, the binding cycle is completed
            T=T+trial_AtpTightBindingT;
            Status = 'Completed';
            %disp(Status);
            %disp([num2str(T) ' sec']);
        else
            %the pocket releases the loosely-bound ATP, is now empty
            T=T+trial_AtpLooseReleaseT;
            Status = 'Empty';
            %disp(Status);
        end
    end
    
    if strcmp(Status,'Empty') %if the pocket is empty
        
        %if we have no ADP in solution, only ATP can bind to the pocket
        if isnan(AdpBindingT)
            %AdpBindingT=NaN, no ADP in solution
            temp = MonteCarlo_DrawRandomExponentialTime(AtpLooseBindingT);
            T=T+temp;
            Status='ATP-LooselyBound';
        else
            %we have both ATP and ADP in solution, both can bind
            trial_AdpBindingT      = MonteCarlo_DrawRandomExponentialTime(AdpBindingT);
            trial_AtpLooseBindingT = MonteCarlo_DrawRandomExponentialTime(AtpLooseBindingT);

            %whichever happens first goes
            if trial_AtpLooseBindingT < trial_AdpBindingT
                %the pocket has loosely bound ATP
                %the pocket can now either bing ATP tightly or loose-release the ATP
                T=T+trial_AtpLooseBindingT;
                Status='ATP-LooselyBound';
                %disp(Status);
            else
                %the pocket has bound ADP
                %at this point we will have to re-start the ADP release cycle
                T=T+trial_AdpBindingT;
                Status='ADP-Bound';
                %disp(Status);
            end
        end
    end
end