function [dat, cmt] = timeshareread(infp, dtype)
%Rewrite of ReadMattFile v8
%Reads a timeshared data file (usually named YYMMDD_NNN.dat, also reads associated _pos, _fl data if available
%Outputs a struct with fieldnames = detector names (raw QPD / etc. signals)

if nargin < 1 || isempty(infp)
    [f, p] = uigetfile('*.dat');
    infp = [p f];
    if ~p
        return
    end
end

if nargin < 2
    dtype = 'int16'; %for meitner; boltzmann is single
    %seems like the Boltzmann VI was altered to , upon averaging, convert the input int16s (2 bytes) to singles (4 bytes) for.. reasons?
end

%open file, big-endian
fid = fopen(infp, 'r', 'b');

%read header: first is a double saying its length, then read the rest (also doubles)
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
13 extra data saved (i.e. if there exists other file with fluor data)
14+ parameters specific to datatype
%}

%Let's take the ones we actually need
ver = hdr(1);
Fsamp = hdr(3);
chnn = hdr(4);
chnid = hdr(5);
dtyp = hdr(6);

%process header 14+, unfinished, just renames things in hdr
if ver >= 9
    switch dtyp
        case 3
            meta.scandim = hdr(14); %denotes scan dimension of raster scan
        case 0
            meta.stageX = hdr(14);
            meta.stageY = hdr(15);
            meta.stageZ = hdr(16);
            meta.profileY = hdr(17);
    end
end
meta.hdr = hdr;
%does this metadata processing need to be done here? or let downstream apps do it?

%read comment
cmtlen = fread(fid, 1, 'double');
cmt = fread(fid, cmtlen, '*char')';

%read PSD data (int16 -> [-10, 10]: can be stored as single-precison float)
data = fread(fid, dtype); %flzr is int16, boltz is single
fclose(fid);
%shape data into nchannels rows
% data = reshape(data, chnn, []);
%Sometimes data isn't a multiple of chnn.... so just force it to be
nrow = floor(numel(data)/chnn);
data = reshape(data(1:nrow*chnn), chnn, nrow);

len = size(data, 2);

%convert to volts
data = data/3276.7; %conversion factor, = (2^15 - 1)/10 - i.e. intmax('int16') / 10 - converts the value from int16 to a number in [-10-1/32767, 10]
%16-bit since that's the way the FPGA handles them - it's the rawest of data

%get channel IDs from chanpattern
%each case assigns these three variables:
% chnnms : the structure fieldname that will identify the detector
% chnind : the index of data(i,:) that corresponds to that fieldname
% chnpol : some channels are negated, store that factor here
switch chnid
    case 1 %12 data chns
        chnnms = {'AY' 'AX' 'AS' 'BY' 'BX' 'BS' 'AFbS' 'BFbS' 'CY' 'CX' 'SCY' 'SCX'};
        chnind = 1:12;
        chnpol = ones(1,12);
    case 2 % 14 data chns
        chnnms = {'AY' 'AX' 'AS' 'BY' 'BX' 'BS' 'AFbX' 'AFbS' 'BFbX' 'BFbS' 'CY' 'CX' 'SCY' 'SCX'};
        chnind = [1:13 13];
        chnpol = [1 1 1 1 1 1 -1 -1 -1 -1 1 1 1 -1];
        % AFbXY BFbXY CXS is negated
    case 3 %8 chns, , only one trap, set A = B and write both
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
%Decided that normalizing here is probably a bad idea
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
    [p, n, e] = fileparts(infp);
    %check for file existence
    flfile = [p filesep n '_fl' e];
    if exist(flfile, 'file')
        flfid = fopen(flfile, 'r', 'b');
        flhdrlen = fread(flfid, 1, 'double'); %this is always eight for now
        flhdr = fread(flfid, flhdrlen, 'double');
        fldat = fread(flfid, 'uint64');
        dat.Fl = uint16(fldat)';
        %check to make sure no values overflew
        if any(dat.Fl == intmax('uint16'))
            dat.Fl = fldat;
            warning('Fluorescence values in file %s unexpectedly high, saving as uint64', n);
        end
        fclose(flfid);
        meta.flhdr = flhdr;
    else
        warning('fluorescence data for file %s was expected but not found', n)
    end
end

%Trap positions are saved if "extradata" (hdr(13)) = 2 or 3
%Trap MHz are usually in the range [30 90], use single
if any(hdr(13) == [2 3])
    [p, n, e] = fileparts(infp);
    posfile = [p filesep n '_pos' e];
    if exist(posfile, 'file')
        posfid = fopen(posfile, 'r', 'b');
        poshdrlen = fread(posfid, 1, 'double');
        poshdr = fread(posfid, poshdrlen, 'double');
        posdat = fread(posfid, 'uint64');
        posdat = single(reshape(posdat, 2, []) *49.152e6*6/1e6/2^48); %conversion factor, copied directly from M.Comstock
        %these values for e.g. passive data may be off by ~eps (the granularity of the int->MHz conversion). Can consider doing round(num * 1e5) / 1e5, but error is O(1e-5), insignificant
        dat.T1F = posdat(1,:);
        dat.T2F = posdat(2,:);
        fclose(posfid);
        meta.poshdr = poshdr;
    else
        warning('trap pos data for file %s was expected but not found', n)
    end
end

%append metadata
dat.meta = meta;