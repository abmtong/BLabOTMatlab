function out = h5calread(infp)

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
    end
end