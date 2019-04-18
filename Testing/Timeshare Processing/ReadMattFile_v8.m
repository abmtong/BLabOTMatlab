function data = ReadMattFile_v8(startpath,rootfile)
%Varsha: startpath = [datadirectories Date '\']; and datadirectories are definied
%in the startup file. rootfile = [Date '_' num2str(datafilenumber,'%03d')
%'.dat']. rootfile is the actual data file, example rootfile =
%141008_012.dat

%function to read Matt's data files with headers.
%090218 mjc
%added ability to read trap position files
%101025 mjc

%open file
if nargin < 1
    [f, p] = uigetfile('*.dat');
    fid = fopen([p f],'r','ieee-be');
else
    fid = fopen([startpath rootfile],'r','ieee-be');
end

%read number of header entries following
fread(fid,1,'float64'); %number of header entries following

%read version number of file format
data.version = fread(fid,1,'float64');

data.rawperiod = fread(fid,1,'float64');%raw sampling period of data before averaging for saving (s)

data.sampperiod = fread(fid,1,'float64');%sampling period of data (s)
data.nchannels = fread(fid,1,'float64');%number of data channels
data.chanpattern = fread(fid,1,'float64');%channel pattern identifier
data.datatype = fread(fid,1,'float64');%data type identifier

%now trap positions, three AOD x,y frequency pairs written, even if only
%one trap is being used and no interlacing.  These positions are also the
%starting positions for raster scans.
data.t1x = fread(fid,1,'float64');
data.t1y = fread(fid,1,'float64');
data.t2x = fread(fid,1,'float64');
data.t2y = fread(fid,1,'float64');
data.t3x = fread(fid,1,'float64');
data.t3y = fread(fid,1,'float64');

%1 or 3 (odd) if fluorescence data was saved (in another file)
%2 or 3 if position data saved
data.extrasaved = fread(fid,1,'float64');

if data.extrasaved == 1
    data.flsaved = 1;
    data.trpossaved = 0;
elseif data.extrasaved == 2
    data.flsaved = 0;
    data.trpossaved = 1;
elseif data.extrasaved == 3
    data.flsaved = 1;
    data.trpossaved = 1;
else
    data.flsaved = 0;
    data.trpossaved = 0;    
end  

if data.version <= 8
    %next four values are not used yet
    for i = 1:4
        fread(fid,1,'float64');
    end
elseif data.version >= 9
    if data.datatype == 3 %trap raster scan
        data.scan2dor1d = fread(fid,1,'float64');
        %next three values are not used yet
        for i = 1:3
            fread(fid,1,'float64');
        end

    elseif data.datatype == 0 %time series
        data.stageX = fread(fid,1,'float64');
        data.stageY = fread(fid,1,'float64');
        data.stageZ = fread(fid,1,'float64');
        data.profileY = fread(fid,1,'float64');
    else
    %next four values are not used yet
    for i = 1:4
        fread(fid,1,'float64');
    end
end

%read raster scan parameters if a raster scan
if data.datatype == 2 %AOM raster scan
    data.scandir = fread(fid,1,'float64');%1 = x scan, 0 = y scan
    data.scanrange = fread(fid,1,'float64');%scan range (MHz), sign gives direction
    data.nsteps = fread(fid,1,'float64');%number of frequency steps per scan
    data.ncycles = fread(fid,1,'float64');%number of cycles per step
    data.nscanfb = fread(fid,1,'float64');%number of scans, forward and back (always come in pairs)
elseif data.datatype == 3 %MCL raster scan
    data.scandir = fread(fid,1,'float64');%1 = x scan, 0 = y scan
    data.scanrange = fread(fid,1,'float64');%scan range (V), sign gives direction
    data.nsteps = fread(fid,1,'float64');%number of voltage steps per scan
    data.ncycles = fread(fid,1,'float64');%number of cycles per step
    data.nscanfb = fread(fid,1,'float64');%the number of scan lines, forward and back (always come in pairs)
    data.initialx = fread(fid,1,'float64');%initial x position (to know where scan starts from)
    data.initialy = fread(fid,1,'float64');%initial y position
end

%now read a comment string
nstrbytes = fread(fid,1,'float64');%number of string bytes
data.comment = (fread(fid,nstrbytes,'*char'))';

%now read data
D = fread(fid,inf,'int16');

fclose(fid);

%reshape
D = (reshape(D,data.nchannels,[]))'; % Varsha why is there an ' at the end

%convert to voltages
D = D/3276.7;

% data.path = startpath;
% data.file = rootfile;

switch data.chanpattern
    case 1      
        data.A_Y = D(:,1)';
        data.A_X = D(:,2)';
        data.A_Sum = D(:,3)';

        data.B_Y = D(:,4)';
        data.B_X = D(:,5)';
        data.B_Sum = D(:,6)';

        data.A_FB_Sum = D(:,7)';
        data.B_FB_Sum = D(:,8)';

        data.C_Y = D(:,9)';
        data.C_X = D(:,10)';
        data.C_Y_Sum = D(:,11)';
        data.C_X_Sum = D(:,12)';

        data.time = (0:(length(data.A_X)-1))*data.sampperiod;
        
        %normalize position data
        data.A_Y = data.A_Y./data.A_Sum;
        data.A_X = data.A_X./data.A_Sum;
        data.B_Y = data.B_Y./data.B_Sum;
        data.B_X = data.B_X./data.B_Sum;
        data.C_Y = data.C_Y./data.C_Y_Sum;
        data.C_X = data.C_X./data.C_X_Sum;

    case 2 %two traps, FB detector X + sum
        data.A_Y = D(:,1)';
        data.A_X = D(:,2)';
        data.A_Sum = D(:,3)';

        data.B_Y = D(:,4)';
        data.B_X = D(:,5)';
        data.B_Sum = D(:,6)';

        data.A_FB_X = -D(:,7)';
        data.A_FB_Sum = -D(:,8)';

        data.B_FB_X = -D(:,9)';
        data.B_FB_Sum = -D(:,10)';

        data.C_Y = D(:,11)';
        data.C_X = D(:,12)';
        data.C_Y_Sum = D(:,13)';
        data.C_X_Sum = -D(:,13)';

        data.time = (0:(length(data.A_X)-1))*data.sampperiod;

        %normalize position data
        data.A_Y = data.A_Y./data.A_Sum;
        data.A_X = data.A_X./data.A_Sum;
        data.B_Y = data.B_Y./data.B_Sum;
        data.B_X = data.B_X./data.B_Sum;
        data.C_Y = data.C_Y./data.C_Y_Sum;
        data.C_X = data.C_X./data.C_X_Sum;
        data.A_FB_X = data.A_FB_X./data.A_FB_Sum;
        data.B_FB_X = data.B_FB_X./data.B_FB_Sum;
        
    case 4 %two traps, FB detector X + Y + sum
        data.A_Y = D(:,1)';
        data.A_X = D(:,2)';
        data.A_Sum = D(:,3)';

        data.B_Y = D(:,4)';
        data.B_X = D(:,5)';
        data.B_Sum = D(:,6)';

        data.A_FB_Y = -D(:,7)';
        data.A_FB_X = -D(:,8)';
        data.A_FB_Sum = D(:,9)';

        data.B_FB_Y = -D(:,10)';
        data.B_FB_X = -D(:,11)';
        data.B_FB_Sum = D(:,12)';

        data.C_Y = D(:,13)';
        data.C_X = D(:,13)';
        data.C_Y_Sum = D(:,14)';
        data.C_X_Sum = -D(:,14)';

        data.time = (0:(length(data.A_X)-1))*data.sampperiod;

        %normalize position data
        data.A_Y = data.A_Y./data.A_Sum;
        data.A_X = data.A_X./data.A_Sum;
        data.B_Y = data.B_Y./data.B_Sum;
        data.B_X = data.B_X./data.B_Sum;
        data.C_Y = data.C_Y./data.C_Y_Sum;
        data.C_X = data.C_X./data.C_X_Sum;
        data.A_FB_Y = data.A_FB_Y./data.A_FB_Sum;
        data.A_FB_X = data.A_FB_X./data.A_FB_Sum;
        data.B_FB_Y = data.B_FB_Y./data.B_FB_Sum;
        data.B_FB_X = data.B_FB_X./data.B_FB_Sum;

    case 3 %one trap, FB detector position and sum
        data.A_Y = D(:,1)';
        data.A_X = D(:,2)';
        data.A_Sum = D(:,4)';

        %just a copy of A
        data.B_Y = D(:,1)';
        data.B_X = D(:,2)';
        data.B_Sum = D(:,4)';

        data.A_FB_X = -D(:,8)';
        data.A_FB_Sum = D(:,3)';

        data.C_Y = D(:,5)';
        data.C_X = D(:,6)';
        data.C_Y_Sum = D(:,7)';
        data.C_X_Sum = -D(:,7)';

        data.time = (0:(length(data.A_X)-1))*data.sampperiod;

        %normalize position data
        data.A_Y = data.A_Y./data.A_Sum;
        data.A_X = data.A_X./data.A_Sum;
        data.B_Y = data.B_Y./data.B_Sum;
        data.B_X = data.B_X./data.B_Sum;
        data.A_FB_X = data.A_FB_X./data.A_FB_Sum;
        
    case 0 %one trap, FB detector sum
        data.A_Y = D(:,1)';
        data.A_X = D(:,2)';
        data.A_Sum = D(:,4)';

        data.A_FB_Sum = D(:,3)';

        data.B_Y = D(:,5)';
        data.B_X = D(:,6)';
        data.B_Y_Sum = D(:,7)';
        data.B_X_Sum = D(:,8)';
        data.B_Sum = D(:,7)';

        data.time = (0:(length(data.A_X)-1))*data.sampperiod;

        %normalize position data
        data.A_Y = data.A_Y./data.A_Sum;
        data.A_X = data.A_X./data.A_Sum;
        data.B_Y = data.B_Y./data.B_Sum;
        data.B_X = data.B_X./data.B_Sum;

end

%now read fluorescence data file if it exists
if data.flsaved == 1
    fid = fopen([startpath rootfile(1:(end-4)) '_fl.dat'],'r','ieee-be');
    
    %read number of header entries following
    fread(fid,1,'float64');%number of header entries following
    
    data.flintperiod = fread(fid,1,'float64');%APD integration period of data (s)
    
    data.napdsampstep = fread(fid,1,'float64');%number of APD samples per scan step (only meaningful for a scan)
    
    %next 6 entries are reserved for now
    for i = 1:6
        fread(fid,1,'float64');
    end
    
    %now read data to the end of the file, the two APD's are interlaced
    F = fread(fid,inf,'uint32');
    
    fclose(fid);

    %reshape to separate APD 1 and 2
    F = (reshape(F,2,[]))';
    
    data.apd1 = F(:,1)';
    data.apd2 = F(:,2)';
    
    data.apdtime = (1:length(data.apd1))*data.flintperiod;

end

%now read trap position data file if it exists
if data.trpossaved == 1
    fid = fopen([startpath rootfile(1:(end-4)) '_pos.dat'],'r','ieee-be');
    
    %read number of header entries following
    fread(fid,1,'float64');%number of header entries following
        
    %next 8 entries are reserved for now
    for i = 1:8
        fread(fid,1,'float64');
    end
    
    %now read dasumed for now)
    F = fread(fid,inf,'uint64');%might work
    
    %reshape to separate traps 1 and 2
    F = (reshape(F,2,[]))';
    
    data.trappos1 = F(:,1)'*49.152e6*6/(1e6*2^48);%convert to frequency
    data.trappos2 = F(:,2)'*49.152e6*6/(1e6*2^48);
    
    fclose(fid);

end

% assignin('base','data',data);

% display(['Loaded ' rootfile]);

end