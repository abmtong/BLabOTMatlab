function t=MonteCarlo_DrawRandomExponentialTime(MeanT)
% This function draws a random time for an exponentially distributed
% process with a mean lifetime MeanT (we're talking single exponential
% here). This is done using the standard Monte Carlo method. Note that
% we're working in the range 0 to 10*MeanT, so you can't have a lifetime
% longer than 10*MeanT here. Feel free to change that if needed.
%
% USE: t=MonteCarlo_DrawRandomExponentialTime(MeanT)
%
% Gheorghe Chistol, 9 Mar 2011

MaxT=10*MeanT; %upper limit for the lifetime, lower limit is zero

t=NaN; %we haven't picked t yet
while isnan(t)
    n1=rand; %draw a random number between 0 and 1
    CandidateT=n1*MaxT; %this is our lifetime candidate
    n2=rand; %draw the second random number for MonteCarlo selection
    if exp(-CandidateT/MeanT) >= n2
        %this candidate passes the test, is accepted
        t=CandidateT;
    end
    %no need to use else here, if the candidate fails the test, the
    %procedure will be repeated until the new candidate is accepted
end
