function out = readh5fxtest()


dr = 'C:\Users\Alexander Tong\Box Sync\Year 2 Semester 2\Res\MATLAB\Testing\h5tstr\bluelake_data\';

p = dr;
f = '\20180611-142601 FD Curve 1.h5';

% [f, p] = uigetfile([dr '.h5']);

%F-X

ext1 = h5read([p f], '/Distance/Distance 1');
ext2 = h5read([p f], '/Distance/Distance 2');
fx1 = h5read([p f], '/Force HF/Force 1x');
fy1 = h5read([p f], '/Force HF/Force 1y');
fx2 = h5read([p f], '/Force HF/Force 2x');
fy2 = h5read([p f], '/Force HF/Force 2y');

fx1l = h5read([p f], '/Force LF/Force 1x');
fy1l = h5read([p f], '/Force LF/Force 1y');
fx2l = h5read([p f], '/Force LF/Force 2x');
fy2l = h5read([p f], '/Force LF/Force 2y');

figure, plot(ext1.Value-ext2.Value, hypot( (fx2l.Value-fx1l.Value)/2, (fy2l.Value-fy1l.Value)/2) );
figure, plot(smooth(-fx1,250))



%Scan
%
grn = h5read([p '20180611-160223 Scan 30.h5'], '/Photon count/Green/');
loc = h5read([p '20180611-160223 Scan 30.h5'], '/Info wave/Info wave/');
blu = h5read([p '20180611-160223 Scan 30.h5'], '/Photon count/Blue/');
red = h5read([p '20180611-160223 Scan 30.h5'], '/Photon count/Red/');
g = drawimage(loc, grn);
r = drawimage(loc, red);
b = drawimage(loc, blu);
img(:,:,1) = r;
img(:,:,2) = g;
img(:,:,3) = b;

figure, imshow(img/max(max(max(img))));

%}


%kymo
%{
grn = h5read([p 'ky.h5'], '/Photon count/Green/');
loc = h5read([p 'ky.h5'], '/Info wave/Info wave/');
blu = h5read([p 'ky.h5'], '/Photon count/Blue/');
red = h5read([p 'ky.h5'], '/Photon count/Red/');
g2 = drawimage(loc, grn, 1);
r2 = drawimage(loc, red, 1);
b2 = drawimage(loc, blu, 1);
img2(:,:,1) = r2;
img2(:,:,2) = g2;
img2(:,:,3) = b2;
figure, imshow(img2/max(max(max(img2))));
%}

%pt scn
%{
grn = h5read([p 'ps1.h5'], '/Photon count/Green/');
blu = h5read([p 'ps1.h5'], '/Photon count/Blue/');
red = h5read([p 'ps1.h5'], '/Photon count/Red/');
figure, plot(grn, 'Color', 'g'), hold on, plot(blu, 'Color', 'b'), plot(red, 'Color', 'r')
%}

%read cal., reads first cal.
calinf = h5info([p 'ky.h5'], '/Calibration');
calinf = calinf.Groups(1);
'kappa (pN/nm)';
cal = [];
for i = 1:4
    nm = calinf.Groups(i).Name;
    nm = nm([end,end-1]); %Names are 'Calibrartion/#/Force 1x', extract the "1x" part and make it 'x1' so it's a valid fieldname
    atts = calinf.Groups(i).Attributes;
    
    ka = atts( strcmp( 'kappa (pN/nm)', {atts.Name} )).Value;
    al = atts( strcmp( 'Rd (um/V)'    , {atts.Name} )).Value;
    cal.(nm).k = ka;
    cal.(nm).a = al;
end


%use average values
texthi = guesstrapext(ext1.Value, fx1l.Value, fy1l.Value, ext2.Value, fx2l.Value, fy2l.Value, cal);

%use instantaneous values
ext1.Timestamp([1, end])

figure, plot(ext1.Value-ext2.Value), hold on, plot(texthi)
x = 1:length(texthi);
lf = polyfit(x,texthi', 1);
y = polyval(lf, x);
plot(x, y)
figure, plot(y-texthi')





