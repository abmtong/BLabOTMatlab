function out = processDatVarIn(numLanes, wantedLanes)
%Opens a raw .dat file and outputs the data in a struct.
%Flexible for non-standard (non-8--lane) data formats
%numLanes = number of data lanes; default 8
%wantedLanes = array of wanted lanes, e.g. [5, 9] for Mx, L9; default all
%Index ref: 1=ay, 2=by, 3=ax, 4=bx, 5=mx, 6=my, 7=sa, 8=sb
%Further lanes are named l[Lane#], i.e. 9=l9, 10=l10, etc.

%Set defaults
if(nargin < 1)
    numLanes = 8;
end
if(nargin < 2)
    wantedLanes = 1:numLanes;
end

%Pick (one) file from UI
[file, path] = uigetfile('.dat');
%The data is stored as a little endian single-precision float (8 bytes); endianness fixed later
data=memmapfile([path filesep file], 'Format', 'single');

%Sanity Check: data length is a multiple of numLanes
if mod(length(data.Data),numLanes) ~= 0
    disp 'Warning: data length seems wrong, are you sure numLanes is right?'
end

%Grab each wanted lane 
for i = 1:length(wantedLanes);
    lane = wantedLanes(i);
    temp = swapbytes(data.Data(lane:numLanes:end));
    switch(lane) % Name it
        case 1
            out.ay = temp;
        case 2
            out.by = temp;
        case 3
            out.ax = temp;
        case 4
            out.bx = temp;
        case 5
            out.mx = temp;
        case 6
            out.my = temp;
        case 7
            out.sa = temp;
        case 8
            out.sb = temp;
        otherwise %for other values, name it out.s[lane#]
            name = ['s'  num2str(lane)];
            out.(name) = temp;
    end
end
end