function [cal, out] = h5calread(infp)
%Lumicks naming in out, my naming in cal

if nargin<1
    dr = fileparts(mfilename('fullpath'));
    [f, p] = uigetfile([dr '.h5']);
    infp = [p f];
end

calinf = h5info(infp, '/Calibration');
calinf = calinf.Groups(:);
out = [];
for j = 1:length(calinf)
    fn = formath5fn(calinf(j).Name);
    curcal = calinf(j);
    for i = 1:4
        nm = curcal.Groups(i).Name;
        nm = nm([end,end-1]); %Names are 'Calibrartion/#/Force 1x', extract the "1x" part and make it 'x1' so it's a valid fieldname
        atts = curcal.Groups(i).Attributes;
        
        ka = atts( strcmp( 'kappa (pN/nm)', {atts.Name} )).Value;
        al = atts( strcmp( 'Rd (um/V)'    , {atts.Name} )).Value;
        out.(fn).(nm).k = ka;
        out.(fn).(nm).a = al;
        out.(fn).(nm).ak = ka*al;
        %Just return the last cal, if multiple exist
        switch nm
            %Lumicks traps are 1 fixed / 2 movable, usually with 2 to the right, so 1 is B and 2 is A
            case 'x1'
                cn = 'BX';
            case 'x2'
                cn = 'AX';
            case 'y1'
                cn = 'BY';
            case 'y2'
                cn = 'AY';
        end
        cal.(cn).k = ka;
        cal.(cn).a = al;
        cal.(cn).ak = ka*al;
    end
end