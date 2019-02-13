function [phageDataInd, ind] = GheLoadPhageList(phageData, IndexFile)
% This function is customized for step finding in HIP traces. It requires an
% IndexFile that has a line of data for each sub-trace. It simply reads the
% names of all phage traces and returns them.
% DataFileName SubTrace# Bandwidth
%
% Example:
% 070108N90.dat     9   100
% 092008N40.dat     7   150
% 091608N15.dat     12  150
% 092308N45.dat     9   150
%
% Gheorghe Chistol, 16 June 2010

[fileList, stepList, bandList] = textread(IndexFile, '%s %u %u');
phageNames = {phageData.file};
phageSteps = [phageData.stID];
ind = [];
Band = [];
for i=1:length(fileList)
    % Find the index for the i-th file from the fileList
    % Find the index for the i-th step from the stepList, now that we found
    % the index of the i-th phage (which might have more than one step
    % listed)
    PhageInd = find(strcmp(phageNames,fileList(i)));
    StepInd  = find(phageSteps(PhageInd)==stepList(i));
    % Produce final index
    ind  = [ind  PhageInd(StepInd)];
    Band = [Band bandList(i)];
end
phageDataInd = phageData(ind);
for i=1:length(phageDataInd)
    phageDataInd(i).Band = Band(i);
end