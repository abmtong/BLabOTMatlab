function Dwells = GheCleanUpDwells(PhageData, Dwells, Nmin, MinStep)
% This function runs GheResolveShortAndCloseDwells as many times as
% neccessary until all short dwells and dwells that are too close to each
% other are cleaned up. GheResolveShortAndCloseDwells cleans up the short
% dwells and close dwells one pass at a time and we may need to run it a
% few times until all the issues are resolved.
%
% Use: Dwells = GheReviewDwells(PhageData, Dwells, Nmin, MinStep)
% Gheorghe Chistol, June 11, 2010

%Status can be either 'Nothing' or 'Merged'
%run the first round of dwell clean-up
[Dwells Status] = GheResolveShortAndCloseDwells(PhageData, Dwells, Nmin, MinStep);
Round=1; %this is the first round of dwell review

while strcmp(Status,'Merged')
    %continue cleaning up the dwells until there is nothing more to do
    [Dwells Status] = GheResolveShortAndCloseDwells(PhageData, Dwells, Nmin, MinStep);
    Round=Round+1; %keep track of the number of rounds
end
%disp(['    GheCleanUpDwells: Dwells Cleaned Up in ' num2str(Round) ' rounds']);