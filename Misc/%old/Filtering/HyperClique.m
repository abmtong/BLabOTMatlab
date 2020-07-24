function [ output_args ] = HyperClique( input_args )
%Removes outliers by looking for "HyperCliques", 

%%How would we define a "set"? adjacent points?
%Search for HCs by binning along Y, look for points that are Y (and X?) -correlated 


% Xiong, Pandley, Steinbach, Kumar, 2006. https://doi.org/10.1109/TKDE.2006.46


end

function hconf = calcHConf(inData, inSet)

confs = zeros(1,length(inSet));
for i = 1:length(inSet)
    findAll = 
    findOne = 
    confs(i) = findAll / findOne;
end    
hconf = min(confs);
end