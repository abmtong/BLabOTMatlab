function out = plotFluorCon(insd)


%Fluorescence downsample amount
fldsamp = 100;


%Get data
con = insd.contour{1};
contim = insd.time{1};

fl = insd.apd1;
fltim = insd.apdT;


%Downsample fluor
fl = windowFilter(@mean, fl, [], fldsamp);
fltim = windowFilter(@mean, fltim, [], fldsamp);

%Downsample contour to match
condsamp = round(length(con) / length(fl) * fldsamp/2);
con = windowFilter(@mean, con, condsamp, round(condsamp/2));
contim = windowFilter(@mean, contim, condsamp, round(condsamp/2));

%Interpolate to match
conint = interp1(contim, con, fltim, 'linear', 0);


%Plot
figure, plot(conint, fl)







