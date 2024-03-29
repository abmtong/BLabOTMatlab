function out = renametophage(in, sn)
%For use by PhageGUI, converts the naming conventions of files processed by different
% methods to those used by me, so PGUI can open them
%Essentially makes them have fields {time, contour, force}, each a cell array of values

out = in;
switch sn
    case 'stepdata'
        %Regular phage, do nothing
    case 'ContourData'
        %Phage F-X data, should probably be shown in ForExtGUI but eh let it be openable here
        out.time = {in.time};
        out.extension = {in.extension};
        out.contour = {in.extension};
        out.force = {in.force};
        out.forceAX = {out.forceAX};
        out.forceAY = {out.forceAY};
        out.forceBX = {out.forceBX};
        out.forceBY = {out.forceBY};
    case 'trace'
        %Antony's analysis code
        out.time = {in.time};
        out.contour = {in.dist};
        out.extension = {in.dist};
        out.force = {in.force};
    case 'tsdata'
        %My code for analysis of timeshared data
        out.time = {in.time};
        out.contour = {in.extension};
        out.force = {in.force};
        out.forceAX = {out.forceAX};
        out.forceAY = {out.forceAY};
        out.forceBX = {out.forceBX};
        out.forceBY = {out.forceBY};
    case 'output'
        %Some of Ronen/Antony's Tx data is in this format
        out.time = {in.time};
        out.extension = {in.signal};
        out.contour = {in.signal};
        out.force = {in.force};
    case 'nanodata'
        %My code for Nanopore data
        out.time = {in.time};
        out.extension = {in.cur};
        out.contour = {in.cur};
        out.force = {in.vol};
    otherwise
        out = [];
        warning('Struct name %s is unrecognized', sn)
end