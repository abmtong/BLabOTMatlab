function outhdr = timesharereadhdr(infp)
%Reads a timeshared data file (usually named YYMMDD_NNN.dat, also reads associated _pos, _fl data if available
%Outputs a struct with the header (what is usually out.meta in timeshareread)

%TODO: Name the numbers in hdr

if nargin < 1 || isempty(infp)
    [file, path] = uigetfile('*.dat');
    infp = [path file];
    if ~path
        return
    end
end

%Separate to path, file, ext
[path, file, ext] = fileparts(infp);

%Open file, big-endian
fid = fopen(infp, 'r', 'b');

%Read header: first number is a double saying its length, then read that many numbers (all doubles)
hdrlen = fread(fid, 1, 'double');
hdr = fread(fid, hdrlen, 'double');

%hdr is usually this:
%{
01 version no.
02 raw samp time (s) (15us for Meitner, e.g.)
03 samp time (s) (.0075 for 500 averaging factor in Meitner, e.g.)
04 n channels
05 ID: channel pattern (see below)
06 ID: datatype (IDs special data, like raster scans - unimplemented yet, just declares what the final values are
07-12 trap [1x 1y 2x 2y 3x 3y] (MHz) at time 0 - if traps don't move, can get their pos. here
13 fl/pos saved: this is two bits [ savepos, savefl ] converted to an integer (i.e. an int from 0 to 3)
14+ parameters specific to datatype, such as APD/MCL scan parameters [necessary for analyzing those files]
%}

%Let's take the ones we actually need right now
ver = hdr(1);
Fsamp = hdr(3);
chnn = hdr(4);
chnid = hdr(5);
dtyp = hdr(6);

%Translate the header into what each value means
% Associate hdrfn (header fieldname) with hdrind (hdr index) by >>meta.(hdrfns{i}) = hdr(hdrcns{i})
if ver >= 9
    %All file headers have these beginning values
    hdrfns = {'filever' 'Fsampraw' 'Fsamp' 'nChannels' 'channelID' 'datatype' 'initMHz' 'extraData'};
    hdrind = { 1         2          3       4           5           6          7:12     13};
    %With some (raster scans) have extra info about how the data was taken
    switch dtyp
        case {0 1} %Regular data or Calibration: nothing extra
        case 2 %AOM Raster
            hdrfns = [hdrfns {'scanDir' 'scanRange' 'scanNSteps' 'scanCycPerStep' 'scanNScans'}];
            hdrind = [hdrind { 18        19          20           21               22 }];
        case 3 %MCL Raster
            hdrfns = [hdrfns {'scanIs2D' 'scanAlongX' 'scanRangeV' 'scanNStepsX' 'scanCycPerStep' 'scanStepsYorNScans' 'scanX0' 'scanY0'}];
            hdrind = [hdrind { 14         18           19           20            21               22                   23       24 }];
        otherwise
            hdrfns = [];
            hdrind = [];
            warning('File %s datatype invalid (~=0,1,2,3), metadata not assigned', file)
    end
else
    hdrfns = [];
    hdrind = [];
    warning('File %s version is too old (<9), metadata not assigned correctly', file)
end

%And assign
for i = 1:length(hdrfns)
    meta.(hdrfns{i}) = hdr(hdrind{i});
end

%Save raw hdr just in case
meta.hdr = hdr;

%Read comment. This isn't used in practice (it by default says 'testing confocal setup')
cmtlen = fread(fid, 1, 'double');
cmt = fread(fid, cmtlen, '*char')';

fclose(fid);

%read external data files, if they exist
%Fluorescence is saved if extrasaved = 1 or 3
%Assumedly two APDs -> two channels? need to see a file with fluorescence
%Fluorescence counts are saved as uint64, but probably can do fewer bytes: max rate = 1e6, min saving fsamp is say 100Hz -> max photons/tick = 1e4 < intmax uint16 = 65535
if any(hdr(13) == [1 3])
    %check for file existence
    flfile = [path filesep file '_fl' ext];
    if exist(flfile, 'file')
        %Open file
        flfid = fopen(flfile, 'r', 'b');
        
        %Read header
        flhdrlen = fread(flfid, 1, 'double'); %this is always eight for now
        flhdr = fread(flfid, flhdrlen, 'double');
        apddt = flhdr(1);
        
        %Assign to meta
        meta.apddt = flhdr(1);
        meta.apdNSampPerStep = flhdr(2); %This is only useful if there's also an MCL line scan.
        % I guess since this info is specifically for this channel, as the other scan params apply to the PSD as well
        fclose(flfid);
        
        meta.flhdr = flhdr;
    else
        warning('Fluorescence data for file %s was expected but not found', file)
    end
end

%Trap positions are saved if "extradata" (hdr(13)) = 2 or 3
%Trap MHz are usually in the range [30 90] and come from a uint48. Use double to keep the bit depth
if any(hdr(13) == [2 3])
    posfile = [path filesep file '_pos' ext];
    if exist(posfile, 'file')
        %Open file
        posfid = fopen(posfile, 'r', 'b');
        %Read header. It's all zeros right now.
        poshdrlen = fread(posfid, 1, 'double');
        poshdr = fread(posfid, poshdrlen, 'double');
        fclose(posfid);
        meta.poshdr = poshdr;
    else
        warning('Trap Pos data for file %s was expected but not found', file)
    end
end

%append metadata
outhdr = meta;