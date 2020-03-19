function [dat, cmt] = timeshareread(infp, dtype)
%Rewrite of ReadMattFile v8
%Reads a timeshared data file (usually named YYMMDD_NNN.dat, also reads associated _pos, _fl data if available
%Outputs a struct with fieldnames = detector names (raw QPD / etc. signals)

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

if nargin < 2
    dtype = 'int16'; %for Meitner; Boltzmann is single
    %Seems like the Boltzmann VI converts the FPGA int16s (2 bytes) to singles (4 bytes) when averaging
    % Guessing this is to save against the integer rounding, but really that is at most 1/32767 (=3e-5) which is probs negligible
end

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

%read PSD data (int16 -> [-10, 10]: can be stored as single-precison float without loss: intmax('int16') << eps(single(10))
data = fread(fid, dtype); %flzr is int16, boltz is single
fclose(fid);
%shape data into nchannels rows
% data = reshape(data, chnn, []);
%Sometimes data isn't a multiple of chnn? ... so just force it to be
nrow = floor(numel(data)/chnn);
data = reshape(data(1:nrow*chnn), chnn, nrow);

len = size(data, 2);

%convert to volts
data = data/3276.7; %conversion factor, = (2^15 - 1)/10 - i.e. double(intmax('int16')) / 10 : converts the value from int16 to a number in [-10-1/32767, 10]
%16-bit since that's the way the FPGA handles them (fastest math) - it's the rawest of data

%get channel IDs from chanpattern
%each case assigns these three variables:
% chnnms : the structure fieldname that will identify the detector
% chnind : the index of data(i,:) that corresponds to that fieldname
% chnpol : some channels are negated, store that factor here
%Some of these writes seem nonsensical; just replicating what ReadMattFile does.
switch chnid
    case 1 %12 data chns
        chnnms = {'AY' 'AX' 'AS' 'BY' 'BX' 'BS' 'AFbS' 'BFbS' 'CY' 'CX' 'SCY' 'SCX'};
        chnind = 1:12;
        chnpol = ones(1,12);
    case 2 % 14 data chns. Flzr default.
        chnnms = {'AY' 'AX' 'AS' 'BY' 'BX' 'BS' 'AFbX' 'AFbS' 'BFbX' 'BFbS' 'CY' 'CX' 'SCY' 'SCX'};
        chnind = [1:13 13];
        chnpol = [1 1 1 1 1 1 -1 -1 -1 -1 1 1 1 -1];
        % AFbXY BFbXY CXS is negated
    case 3 %8 chns, One trap, set A = B and write both
        chnnms = {'AY' 'AX' 'AS' 'BY' 'BX' 'BS' 'AFbX' 'AFbS' 'CY' 'CX' 'SCY' 'SCX'};
        chnind = [1 2 4 1 2 4 8 3 5 6 7 7];
        chnpol = [1 1 1 1 1 1 -1 1 1 1 1 -1];
    case 4 % 14 chns, two traps with fb XYS
        chnnms = {'AY' 'AX' 'AS' 'BY' 'BX' 'BS' 'AFbY' 'AFbX' 'AFbS' 'CY' 'CX' 'SCY' 'SCX'};
        chnind = [1:13 13 14 14];
        chnpol = [1 1 1 1 1 1 -1 -1 1 -1 -1 1 1 1 1 -1];
    case 0 % 9 chns, one trap with feedback XS
        chnnms = {'AY' 'AX' 'AS' 'AFbS' 'BY' 'BX' 'BYS' 'BXS' 'BS'};
        chnind = [1 2 4 3 5 6 7 8 7];
        chnpol = ones(1,9);
    otherwise
        error( 'invalid channel id %d, check ur dat header', chnid);
end

%Assign data to struct fields
dat = [];
for i = 1:length(chnnms);
    dat.(chnnms{i}) = single(data(chnind(i),:) * chnpol(i));
end
%Add time field
dat.T = single( (0:len-1)*Fsamp );

%{
Decided that normalizing here is probably a bad idea
%normalize - not every detector is in every file, declare detector-sum pairs here
fnames = fieldnames(dat);
xys  = {'AX' 'AY' 'BX' 'BY' 'CX' 'CY' 'AFbX' 'AFbY' 'BFbX' 'BFbY'};
sums = {'AS' 'AS' 'BS' 'BS' 'CS' 'CS' 'AFbS' 'AFbS' 'BFbS' 'BFbS'};
for i = 1:length(xys)
    %check if both fields exist
    if any(strcmp(fnames, xys{i})) && any(strcmp(fnames, sums{i}))
        %then normalize
        dat.(xys{i}) = dat.(xys{i}) ./ dat.(sums{i});
    end
end
%}

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
        % I guess since this info is specifically for this channel, as the other scan params apply to the PSD as well.
        
        %Read the actual data
        fldat = fread(flfid, 'uint64');
        tmpfl = uint16(fldat)';
        %check to make sure no values overflew
        if any(tmpfl == intmax('uint16'))
            dat.Fl = fldat;
            warning('Fluorescence values in file %s unexpectedly high, saving as uint64', file);
        end
        %Reshape counts
        tmpfl = (reshape(tmpfl,2,[]));
        dat.APD1 = tmpfl(1,:);
        dat.APD2 = tmpfl(2,:);
        dat.APDT = (0:length(dat.APD1)-1) * apddt; %ReadMattFile started at 1, not 0, causing a delay
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
        %Read data, convert to MHz
        posdat = fread(posfid, 'uint64');
        posdat = double(reshape(posdat, 2, [])) *49.152*6/2^48;
        %The conversion is based on the frequency of the TCXO (49MHz) and that the raw data is stored as a uint48 -> [0 6]
        dat.T1F = posdat(1,:);
        dat.T2F = posdat(2,:);
        fclose(posfid);
        meta.poshdr = poshdr;
    else
        warning('Trap Pos data for file %s was expected but not found', file)
    end
end

%append metadata
dat.meta = meta;