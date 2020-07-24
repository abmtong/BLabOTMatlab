function T=MonteCarlo_LooseAndTightAtpBinding(LooseBindingT,LooseUnbindingT,TightBindingT)
% This function helps simulate ATP binding to an ATPase pocket taking into
% account loose binding rate (time), loose unbinding rate (time), tight
% binding rate (time) and others can be added later. Here we consider tight
% binding to be largely irreversible.
%
% Later add ADP binding/release to the empty pocket 
%
% T=MonteCarlo_LooseAndTightAtpBinding(LooseBindingT,LooseUnbindingT,TightBindingT)
%
% Gheorghe Chistol, 14 March 2011

%start with an empty pocket, ATP can bind loosely to it
T=0;
Status='incomplete';

while strcmp(Status,'incomplete')
    %see how much it takes an ATP to bind to the empty pocket
    t=MonteCarlo_DrawRandomExponentialTime(LooseBindingT);
    T=T+t;

    %now we have two options: either undergo tight binding, or release the ATP
    trial_TightBinding   = MonteCarlo_DrawRandomExponentialTime(TightBindingT);
    trial_LooseUnbinding = MonteCarlo_DrawRandomExponentialTime(LooseUnbindingT);

    %if the TightBinding candidate time is shorter, tight binding will occur
    if trial_TightBinding < trial_LooseUnbinding
        T=T+trial_TightBinding;
        Status = 'complete';
        %tight binding was accomplished, the binding cycle is complete
    else
        T=T+trial_LooseUnbinding;
        Status = 'incomplete';
        %tight binding could not be accomplished, the binding cycle is incomplete
    end
end