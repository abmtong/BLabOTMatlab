function zjPolarPlot(rthy, inOpts)

%Generate the polar plot a la ZJ Chen's paper


%Options:
%Spiral parameters: r and theta
%Defaults are to match style in Chen 2019
opts.th0 = 137.5/180*pi; %Start angle, rad
opts.dth = 2*pi/84; %Angle per bp, or (bp/wrap)^-1
opts.r0 = 282/86 + 120/86*137.5/360; %R-naught, unit is 'seconds' (same as d)
opts.dr = -120/86; %Spiralling amount

%Color
opts.color = [1 0 0];

%Chen figure is:
%{
84 bp per wrap
282 px r0
-120 px dr
-47.5deg th0 is ~x deg , but let's just call this zero and rotate the axis
1.2s pause is 103px
So ~86px/s
%}

opts.method = 2; %Drawing method, see code

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Draw rectangles (well, trapezoid?) for each y 
for i = 1:length(rthy)
    %Generate the four points of this trapezoid
    switch opts.method
        case 1 %ZJ-like
            %Theta
            th1 = opts.th0 + (i-1)* opts.dth;
            th2 = th1 + opts.dth;
            
            %R
            r1 = opts.r0 + (opts.dr * mean(th1+th2)/2/pi);
            r2 = r1 + rthy(i);
            
            %Four points is the four combos of (r, th)
            %x = r cos th ; y = r sin th
            x = [ [r1 r2] * cos(th1) [r2 r1] * cos(th2)];
            y = [ [r1 r2] * sin(th1) [r2 r1] * sin(th2)];
        case 2 %Make baseline smoother
            %Theta
            th1 = opts.th0 + (i-1)* opts.dth;
            th2 = th1 + opts.dth;
            
            %R
            r1 = opts.r0 + (opts.dr * th1/2/pi);
            r2 = r1 + rthy(i);
            r3 = opts.r0 + (opts.dr * th2/2/pi);
            r4 = r3 + rthy(i);
            
            %(r, th) to (x,y)
            x = [ [r1 r2] * cos(th1) [r4 r3] * cos(th2)];
            y = [ [r1 r2] * sin(th1) [r4 r3] * sin(th2)];
    end
    %Draw this trapezoid with patch
    ob = patch('XData', x, 'YData', y);
    ob.FaceColor = opts.color;
    ob.EdgeColor = opts.color;
end