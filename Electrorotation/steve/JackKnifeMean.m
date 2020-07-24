%This script calculates the JackKnife resampled mean and error for an array
%
%Steven Large

function[JackMean,JackStd] = JackKnifeMean(DataArray)

TempMeanArray = {};
TempVarArray = {};

for index=1:length(DataArray)
    TempMeanArray{index} = (sum(DataArray) - DataArray(index))/(length(DataArray)-1); 
end

TempMeanArray = [TempMeanArray{:}];
JackMean = mean(TempMeanArray);

for index=1:length(DataArray)
    TempVarArray{index} = (TempMeanArray(index) - JackMean)^2;
end

TempVarArray = [TempVarArray{:}];
JackVar = ((length(DataArray)-1)/length(DataArray))*sum(TempVarArray);
JackStd = sqrt(JackVar);



