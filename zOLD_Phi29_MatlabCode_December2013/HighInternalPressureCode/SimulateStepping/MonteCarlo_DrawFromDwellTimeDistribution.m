function T=MonteCarlo_DrawFromDwellTimeDistribution(DwellTimeDistribution)
% This function is used when simulating phage stepping.  
% DwellTimeDistribution.t - dwell time values
% DwellTimeDistribution.p - probability density corresponding to the dwell time
% note that p has to be normalized, i.e. sum(p)=1;
% The min and max possible dwell times are given by the min and max of the
% t-vector (usually 0-1sec)
%
% USE: T = MonteCarlo_DrawFromDwellTimeDistribution(DwellTimeDistribution)
%
% Gheorghe Chistol, 06 June 2011

T=NaN; %we haven't picked t yet
while isnan(T)
    n1=rand; %draw a random number between 0 and 1
    CandidateT=n1*max(DwellTimeDistribution.t); %this is our lifetime candidate
    n2=rand; %draw the second random number for MonteCarlo selection
    
    %P = interp1([tBinStart tBinEnd], [pBinStart pBinEnd], CandidateT);
    P = interp1(DwellTimeDistribution.t,DwellTimeDistribution.p,CandidateT);
    if n2<P
        %this candidate passes the test, is accepted
        T=CandidateT;
    end
    %no need to use else here, if the candidate fails the test, the
    %procedure will be repeated until the new candidate is accepted
end
