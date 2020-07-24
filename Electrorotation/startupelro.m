function startupelro()

tp = fileparts(mfilename('fullpath'));
folnam = {'DataProcessing' 'Helpers'};

cellfun(@(x) addpath([tp filesep x]), folnam)