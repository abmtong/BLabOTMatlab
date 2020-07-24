function offset = MakeOffsetFiles_ProcessSingleFile(Params, RawFileName, RawFilePath)
% This function processes a single offset file, generating the structure
% "offset" which is saved by 'GheMakeOffsetFiles' afterward. The reason
% this function exists is to make the whole process modular and easier to
% read the code.
%
% USE: offset = MakeOffsetFiles_ProcessSingleFile(Params, RawFileName, RawFilePath)
%
% Gheorghe Chistol, 09 Feb 2012

    fSample    = Params.fSample;
    nWindow    = Params.nWindow; %size of the window for filtering
    sDirection = Params.sDirection; %scanning direction, 1 for 'X' and 0 for 'Y'
    vThreshold = Params.vThreshold; %voltage threshold for mirror step detection
    frontPad   = Params.frontPad;

    data = MakeOffsetFiles_LoadRawFile(fSample,RawFileName,RawFilePath);
    if sDirection % direction=1 for x, direction=0 for y
        idx = find(abs(diff(filter(ones(1, nWindow), nWindow, data.Mirror_X))) <= vThreshold);
        startInd = [idx(1); idx(find(diff(idx) > 5) + 1)];
        endInd   = [idx(find(diff(idx) > 5)); idx(end)]; %#ok<*FNDSB>
        
    else
        idx = find(abs(diff(filter(ones(1, nWindow), nWindow, data.Mirror_Y))) <= vThreshold);
        startInd = [idx(1); idx(find(diff(idx) > 5) + 1)];
        endInd = [idx(find(diff(idx) > 5)); idx(end)];
    end
    startAll = startInd + frontPad;
    endAll = endInd;
    ind = find((startAll <= endAll) == 1);
    startAll = startAll(ind);
    endAll = endAll(ind); 
    offset.path  = RawFilePath;
    offset.file  = RawFileName;
    offset.stamp = now;
    offset.date  = date;
    offset.param = Params;

    % Calculate mean, std between steps 
    for j = 1:length(startAll);
        offset.Mirror_X(j)    = mean(data.Mirror_X(startAll(j):endAll(j)));  %#ok<*SAGROW>
        offset.Mirror_X_SD(j) = std( data.Mirror_X(startAll(j):endAll(j))); 
        offset.Mirror_Y(j)    = mean(data.Mirror_Y(startAll(j):endAll(j)));
        offset.Mirror_Y_SD(j) = std( data.Mirror_Y(startAll(j):endAll(j)));
        offset.A_X(j)         = mean(data.A_X(startAll(j):endAll(j)));
        offset.A_X_SD(j)      = std( data.A_X(startAll(j):endAll(j)));
        offset.A_Y(j)         = mean(data.A_Y(startAll(j):endAll(j)));
        offset.A_Y_SD(j)      = std( data.A_Y(startAll(j):endAll(j)));
        offset.B_X(j)         = mean(data.B_X(startAll(j):endAll(j)));
        offset.B_X_SD(j)      = std( data.B_X(startAll(j):endAll(j)));
        offset.B_Y(j)         = mean(data.B_Y(startAll(j):endAll(j)));
        offset.B_Y_SD(j)      = std( data.B_Y(startAll(j):endAll(j)));
        offset.A_Sum(j)       = mean(data.A_Sum(startAll(j):endAll(j)));
        offset.A_Sum_SD(j)    = std( data.A_Sum(startAll(j):endAll(j)));
        offset.B_Sum(j)       = mean(data.B_Sum(startAll(j):endAll(j)));
        offset.B_Sum_SD(j)    = std( data.B_Sum(startAll(j):endAll(j)));
        offset.numPoints(j)   = endAll(j)-startAll(j)+1;
    end
    Cutoff_MX = 2.65;
    Cutoff_Upper_MX = 9.9;
    KeepInd = offset.Mirror_X>Cutoff_MX & offset.Mirror_X<Cutoff_Upper_MX;
    offset.Mirror_X    = offset.Mirror_X(KeepInd);
    offset.Mirror_X_SD = offset.Mirror_X_SD(KeepInd); 
    offset.Mirror_Y    = offset.Mirror_Y(KeepInd);
    offset.Mirror_Y_SD = offset.Mirror_Y_SD(KeepInd);
    offset.A_X         = offset.A_X(KeepInd);
    offset.A_X_SD      = offset.A_X_SD(KeepInd);
    offset.A_Y         = offset.A_Y(KeepInd);
    offset.A_Y_SD      = offset.A_Y_SD(KeepInd);
    offset.B_X         = offset.B_X(KeepInd);
    offset.B_X_SD      = offset.B_X_SD(KeepInd);
    offset.B_Y         = offset.B_Y(KeepInd);
    offset.B_Y_SD      = offset.B_Y_SD(KeepInd);
    offset.A_Sum       = offset.A_Sum(KeepInd);
    offset.A_Sum_SD    = offset.A_Sum_SD(KeepInd);
    offset.B_Sum       = offset.B_Sum(KeepInd);
    offset.B_Sum_SD    = offset.B_Sum_SD(KeepInd);
    offset.numPoints   = offset.numPoints(KeepInd);    
    
    % handle unique values
    [~, KeepInd] = unique(offset.Mirror_X);
    offset.Mirror_X    = offset.Mirror_X(KeepInd);
    offset.Mirror_X_SD = offset.Mirror_X_SD(KeepInd); 
    offset.Mirror_Y    = offset.Mirror_Y(KeepInd);
    offset.Mirror_Y_SD = offset.Mirror_Y_SD(KeepInd);
    offset.A_X         = offset.A_X(KeepInd);
    offset.A_X_SD      = offset.A_X_SD(KeepInd);
    offset.A_Y         = offset.A_Y(KeepInd);
    offset.A_Y_SD      = offset.A_Y_SD(KeepInd);
    offset.B_X         = offset.B_X(KeepInd);
    offset.B_X_SD      = offset.B_X_SD(KeepInd);
    offset.B_Y         = offset.B_Y(KeepInd);
    offset.B_Y_SD      = offset.B_Y_SD(KeepInd);
    offset.A_Sum       = offset.A_Sum(KeepInd);
    offset.A_Sum_SD    = offset.A_Sum_SD(KeepInd);
    offset.B_Sum       = offset.B_Sum(KeepInd);
    offset.B_Sum_SD    = offset.B_Sum_SD(KeepInd);
    offset.numPoints   = offset.numPoints(KeepInd);    
end