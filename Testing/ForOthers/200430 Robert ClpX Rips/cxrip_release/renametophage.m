function out = renametophage(in, sn)
%For use by PhageGUI, converts the naming conventions of files processed by different
% methods to that used by me, so PGUI can open them
%Essentially makes them have fields {time, contour, force}; each a cell array of values

out = in;
switch sn
    case 'stepdata'
        %Regular phage, do nothing
    case 'ContourData'
        %Phage F-X data, should probably be shown in ForExtGUI but eh let it be openable here
        out.time = {in.time};
        out.contour = {in.extension};
        out.force = {in.force};
    case 'trace'
        %Antony's analysis code
        out.time = {in.time};
        out.contour = {in.dist};
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
    otherwise
        out = [];
        warning('Struct name %s is unrecognized', sn)
end