function out = tsReadGreen(trapfp)
%Reads green (*_grn.dat) data files. @author Alex.

%Use this to append to ReadMattFile if you like, with snippet:
%{
grndat = readGreen(path_to_trap_file)
if ~isempty(grndat)
    ~~Assign Fields to Output Struct~~
end
%}

if nargin < 1
    [f, p] = uigetfile('*_grn.dat');
    grnfp = fullfile(p, f);
else
    [p, f, e] = fileparts(trapfp);
    grnfp = fullfile(p, [f '_grn' e]);
end

if exist(grnfp, 'file')
    fid = fopen(grnfp,'r','ieee-be');
else
    out = [];
    return
end

%Structure like Matt files so..

%Read n header byte
nghdr = fread(fid,1,'float64');
%Read the full header
ghdr = fread(fid, nghdr, 'float64');

%Only one of these is nonzero, it's the front panel update rate
dt = ghdr(1);

%Read the file
gdat = fread(fid, inf, 'float64');

%This is a 4xn array with rows [GrnOn Current% InterlaceMode PDSum]
gdat = reshape(gdat, 4, []);

%GrnOn is a boolean, and == 1 if the laser is on
%InterlaceModeis an enum, where (0,1,2) = (on, off, interlace)

%Assign to output struct
out.GrnOn = gdat(1,:);
out.GrnCurrPct = gdat(2,:);
out.GrnIntMode = gdat(3,:);
out.GrnPDSum = gdat(4,:);
out.GrnTime = (1:length(out.GrnOn))*dt;
