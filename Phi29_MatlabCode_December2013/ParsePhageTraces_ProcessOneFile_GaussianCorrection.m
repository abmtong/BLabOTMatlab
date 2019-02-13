function phage = ParsePhageTraces_ProcessOneFile_GaussianCorrection(Files,Params)
% This function is given the raw file with a phage packaging trace, the
% calibration file and the offset file. It applies the offset and
% calibration and converts the raw data into Time, Force, Extension, and
% Contour Length. This function is called upob by ParsePhageTraces_Batch.
% This is done to improve code readability and make things modular.
%
% Here I apply a gaussian correction to the force, which means that the stiffness at high force is
% not as high as at low force. 4 June 2012, Ghe
%
% USE: phage = ParsePhageTraces_ProcessOneFile(Files,Params)
%
% Gheorghe Chistol, 15 Feb 2012

%     Params.fsamp         = InputParams(1);
%     Params.TrapXconv     = InputParams(2);
%     Params.TrapYconv     = InputParams(3);
%     Params.TrapXoffset   = InputParams(4);
%     Params.TrapYoffset   = InputParams(5);
%     Params.PersLength    = 30; %DNA persistence length in nm
%     Params.StrModulus    = 1200; %DNA stretch modulus, in pN
%     Params.KbT           = 4.14; %boltzmann const, in pN*nm
%     Params.Threshhold    = 0.02;
%     Params.StartShift    = 100;
%     Params.EndShift      = 100;
%     FilterWindow         = Params.FilterWindow;
%     Files.RawFileName    = RawFile{f};
%     Files.RawFilePath    = rawDataPath;
%     Files.CalibFileName  = CalibFile{f};
%     Files.CalibFilePath  = analysisPath{f};
%     Files.OffsetFileName = OffsetFile{f};
%     Files.OffsetFilePath = analysisPath{f};


    %% Load raw data, calibration, offset
    data    = ParsePhageTraces_LoadRawFile(Params.fsamp, Files.RawFileName, Files.RawFilePath);
    temp    = load([Files.OffsetFilePath filesep Files.OffsetFileName],'offset'); %load offset data
    offset  = temp.offset; %if this is confusing, do "help load"
    temp    = load([Files.CalibFilePath filesep Files.CalibFileName],'cal'); %load calibration data
    cal     = temp.cal; clear temp; %if this is confusing, do "help load"

    %% Interpolate Offset Data
    AXoffset = interp1(offset.Mirror_X, offset.A_X, data.Mirror_X, 'linear');
    AYoffset = interp1(offset.Mirror_X, offset.A_Y, data.Mirror_X, 'linear');
    BXoffset = interp1(offset.Mirror_X, offset.B_X, data.Mirror_X, 'linear');
    BYoffset = interp1(offset.Mirror_X, offset.B_Y, data.Mirror_X, 'linear');

    %% Remove Offsets
    caldata.AXPos = cal.alphaAX*(data.A_X-AXoffset); %caldata is a temporary structure to organize intermediate results
    caldata.AYPos = cal.alphaAY*(data.A_Y-AYoffset);
    caldata.BXPos = cal.alphaBX*(data.B_X-BXoffset);
    caldata.BYPos = cal.alphaBY*(data.B_Y-BYoffset);
    
    %% Calculate Forces
    caldata.TrapX   = Params.TrapXconv*(data.Mirror_X-Params.TrapXoffset); %position of steerable trap in X with respect to the fixed trap in nm
    caldata.TrapY   = Params.TrapYconv*(data.Mirror_Y-Params.TrapYoffset); %same for Y
    caldata.ForceAX = (cal.kappaAX*caldata.AXPos).*exp(-caldata.AXPos.^2/(2*200^2)); %275 is sigma of the beam in nm
    caldata.ForceAY = (cal.kappaAY*caldata.AYPos).*exp(-caldata.AYPos.^2/(2*200^2));
    caldata.ForceBX = (cal.kappaBX*caldata.BXPos).*exp(-caldata.BXPos.^2/(2*200^2));
    caldata.ForceBY = (cal.kappaBY*caldata.BYPos).*exp(-caldata.BYPos.^2/(2*200^2));

    ForceX = 0.5*(caldata.ForceBX-caldata.ForceAX); %average X force between the two traps
    ForceY = 0.5*(caldata.ForceBY-caldata.ForceAY); %average Y force between the two traps

    %% Compute Tether Force & Extension the use that to compute Contour
    caldata.time      = data.time;
    caldata.force     = sqrt(ForceX.^2+ForceY.^2);
    if isfield(cal,'beadA') && isfield(cal,'beadB')
        caldata.extension = sqrt((caldata.TrapX+caldata.AXPos-caldata.BXPos).^2   + ...
                                 (caldata.TrapY+caldata.AYPos-caldata.BYPos).^2 ) - ...
                                  (cal.beadA/2+cal.beadB/2); %these are bead diameters
    elseif isfield(cal,'beadRadiusA') && isfield(cal,'beadRadiusB')
        caldata.extension = sqrt((caldata.TrapX+caldata.AXPos-caldata.BXPos).^2   + ...
                                 (caldata.TrapY+caldata.AYPos-caldata.BYPos).^2 ) - ...
                                  (cal.beadRadiusA+cal.beadRadiusB); %these are bead radii
    else
        error('Bead radius/diameter is not defined :(');
    end
    ExtensionDivByContour = ParsePhageTraces_XWLCContour(caldata.force);
    caldata.contour       = real(caldata.extension./ExtensionDivByContour)/0.34; %Contour Length in bp
    
    %% Break up the trace into Feedback Cycles
    TrapX_av = filter(ones(1, Params.FilterWindow), Params.FilterWindow, caldata.TrapX);
    idxX = find(diff(TrapX_av) >= -Params.Threshhold & diff(TrapX_av) <= Params.Threshhold);
    
    %TrapY_av = filter(ones(1,FilterWindow),FilterWindow,caldata.TrapY);
    %idxY = find(diff(TrapY_av) >= -threshhold & diff(TrapX_av) <= threshhold);

    %startX & endX are columns
    startX = [idxX(1); idxX(find(diff(idxX)>1)+1)];
    endX = [idxX(find(diff(idxX)>1)); idxX(end)]; %#ok<*FNDSB>
    startXY = startX;
    endXY = endX;
    % we are doing experiments in x, using x-feedback
    % this would have to be modified for experiments with y-fedback
    % startX and endX are the points where a feedback cycle starts and ends
    % respectively (for example the 7-10pN range)

    phage.path          = Files.RawFilePath;
    phage.file          = Files.RawFileName;
    phage.calpath       = Files.CalibFilePath;
    phage.calfile       = Files.CalibFileName;
    phage.offsetpath    = Files.OffsetFilePath;
    phage.offsetfile    = Files.OffsetFileName;
    phage.date          = date;
    phage.stamp         = now;

    for fc = 1:length(startXY) %'fc' stands for FeedbackCycle index
        phage.time{fc}      = caldata.time(     startXY(fc):endXY(fc) );
        phage.force{fc}     = caldata.force(    startXY(fc):endXY(fc) )';
        phage.extension{fc} = caldata.extension(startXY(fc):endXY(fc) )';
        phage.contour{fc}   = caldata.contour(  startXY(fc):endXY(fc) )';
        phage.trapX{fc}     = caldata.TrapX(    startXY(fc):endXY(fc) );
        phage.trapY{fc}     = caldata.TrapY(    startXY(fc):endXY(fc) );    
    end
end