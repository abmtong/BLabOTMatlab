function [ContourData CalibratedData OffsetData] = ForceExt_ParseTrace_ProcessOneFile_Felix(FileNameAndPath,Params)
% This function loads raw data, offset, calibration, then applies offset
% and calibration to the raw data. This is done to make
% 'ForceExt_ParseTrace_Batch.m' more modular and easier to read.
%
% USE: [ContourData CalibratedData OffsetData] = ForceExt_ParseTrace_ProcessOneFile(FileNameAndPath,Params)
%
% Gheorghe Chistol, 13 Feb 2012

    %Un-package the file names and paths from the convenient structure
    RawFileName    = FileNameAndPath.RawFileName;
    RawFilePath    = FileNameAndPath.RawFilePath;
    OffsetFileName = FileNameAndPath.OffsetFileName;
    OffsetFilePath = FileNameAndPath.OffsetFilePath;
    CalFileName    = FileNameAndPath.CalFileName;
    CalFilePath    = FileNameAndPath.CalFilePath;

    %Un-package the parameters
    fsamp         = Params(1); 
    TrapXconv     = Params(2); 
    TrapYconv     = Params(3);
    TrapXoffset   = Params(4); 
    TrapYoffset   = Params(5);
    
    % Load Raw, Offset, and Calibration files
    data   = ForceExt_ParseTrace_LoadRawFile_Felix(fsamp,RawFileName,RawFilePath);
    offset = load([OffsetFilePath filesep OffsetFileName],'offset'); offset = offset.offset;
    cal    = load([CalFilePath    filesep CalFileName   ],'cal');    cal    = cal.cal; 

    %% Apply Offset and Calibration to Raw Data
    display(['Applying offset and calibration to ' RawFileName]);
    ContourData.Params.fsamp       = fsamp;
    ContourData.Params.TrapXConv   = TrapXconv;
    ContourData.Params.TrapYConv   = TrapYconv;
    ContourData.Params.TrapXOffset = TrapXoffset;
    ContourData.Params.TrapYOffset = TrapYoffset;

    CalibratedData.path = RawFilePath;
    CalibratedData.file = RawFileName;
    CalibratedData.time = data.time;
    CalibratedData.OffsetFile = [OffsetFilePath filesep OffsetFileName];
    CalibratedData.CalFile    = [CalFilePath    filesep CalFileName];

    %Use offset data to interpolate
    AXoffset = interp1(offset.Mirror_X,offset.A_X,data.Mirror_X,'linear');
    AYoffset = interp1(offset.Mirror_X,offset.A_Y,data.Mirror_X,'linear');
    BXoffset = interp1(offset.Mirror_X,offset.B_X,data.Mirror_X,'linear');
    BYoffset = interp1(offset.Mirror_X,offset.B_Y,data.Mirror_X,'linear');

    %Remove Offsets, do your best to save memory
    CalibratedData.AXPos = cal.alphaAX*(data.A_X-AXoffset); clear AXoffset; data.A_X=[];
    CalibratedData.AYPos = cal.alphaAY*(data.A_Y-AYoffset); clear AYoffset; data.A_Y=[];
    CalibratedData.BXPos = cal.alphaBX*(data.B_X-BXoffset); clear BXoffset; data.B_X=[];
    CalibratedData.BYPos = cal.alphaBY*(data.B_Y-BYoffset); clear BYoffset; data.B_Y=[];

    CalibratedData.ForceAX = cal.kappaAX*CalibratedData.AXPos;
    CalibratedData.ForceAY = cal.kappaAY*CalibratedData.AYPos;
    CalibratedData.ForceBX = cal.kappaBX*CalibratedData.BXPos;
    CalibratedData.ForceBY = cal.kappaBY*CalibratedData.BYPos;

    ForceX = 0.5*(CalibratedData.ForceBX-CalibratedData.ForceAX); %'minus' due to direction of the vector
    ForceY = 0.5*(CalibratedData.ForceBY-CalibratedData.ForceAY);

    CalibratedData.TrapX = TrapXconv*(data.Mirror_X-TrapXoffset); data.Mirror_X = []; %clear to save memory
    CalibratedData.TrapY = TrapYconv*(data.Mirror_Y-TrapYoffset); data.Mirror_Y = []; %clear to save memory    

    ContourData.path          = RawFilePath;
    ContourData.file          = RawFileName;
    ContourData.offsetpath    = OffsetFilePath;
    ContourData.offsetfile    = OffsetFileName;
    ContourData.date_modified = date;
    ContourData.calpath       = CalFilePath;
    ContourData.calfile       = CalFileName;
    ContourData.TrapX         = CalibratedData.TrapX;
    ContourData.TrapY         = CalibratedData.TrapY;
    ContourData.ForceX        = ForceX;
    ContourData.ForceY        = ForceY;
    ContourData.time          = data.time;
    ContourData.force         = sqrt(ForceX.^2+ForceY.^2);
    ContourData.extension     = sqrt((CalibratedData.TrapX+CalibratedData.AXPos-CalibratedData.BXPos).^2+ ...
                                     (CalibratedData.TrapY-CalibratedData.AYPos+CalibratedData.BYPos).^2)- ...
                                      cal.beadRadiusA-cal.beadRadiusB;
    OffsetData = offset; %this will be saved to the "ForceExtension_" file
end