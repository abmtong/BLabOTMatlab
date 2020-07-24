function NormVoltage = GheCalibrate_ReadHighFreqFile(FilePath, HighFreqFile)
% Reads high frequency binary data file(s), outputs normalized AX, AY, BX,
% BY voltages. It works one file at a time.
%
% NormVoltage = GheCalibrate_ReadHighFreqFile(FilePath, HighFreqFile)
%
% Gheorghe Chistol, 3 Feb 2012

    prefix = {''   'a'  'b'  'c'  'f'    'g'};    %'d'  'e'  Other detectors, not needed for BrownianCalibration
    name =   {'AY' 'BY' 'AX' 'BX' 'SumA' 'SumB'}; %'MX' 'MY' 
    
    startInd = 85;
    %the files have 42 doubles (=84 singles) as a header containing the hardware scaling coefficients
    %QPD halves are 62500 + 0.0056x + 1.598e-5x^2 + 4.7257e-17x^3 + 2.0473e-20x^4
    %Mirror, sums are 62500 + 0.0276x + 7.988e-5x^2 + 2.362e-14x^3 + 1.023e-17x^4
    
    fprintf(['------ Loading ' HighFreqFile ': ']);
    
    for i = 1:length(prefix)
        file = memmapfile([FilePath filesep prefix{i} HighFreqFile],'Format','single');
        temp.(name{i}) = swapbytes(file.Data(startInd:end));
        clear file;
        fprintf('|');
    end
    
    % Normalize
    NormVoltage.AX = temp.AX./temp.SumA;
    NormVoltage.AY = temp.AY./temp.SumA;
    NormVoltage.BX = temp.BX./temp.SumB;
    NormVoltage.BY = temp.BY./temp.SumB;
    
    fprintf([' done\n']);
end