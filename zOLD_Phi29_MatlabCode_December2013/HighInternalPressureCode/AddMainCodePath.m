% This script adds the folder with the old Phage scripts/functions to the
% Matlab path. These old scripts were written by Jeff and partly by Ghe and
% they can be called from the current folder after adding them to the
% matlab path.

temp=pwd; %current folder, i.e. HighInternalPressureCode
while temp(end)~='\';
    temp(end)='';
end
temp = [temp 'NewAnalysisCode\']; %name of the folder to be added to the Matlab path
addpath(temp, '-end');
clear temp

