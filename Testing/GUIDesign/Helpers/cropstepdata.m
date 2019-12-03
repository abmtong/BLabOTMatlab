function stepdata = cropstepdata(stepdata, tlim)
%Crops the time, contour, force, extension fields in stepdata to be within crop

%Accomplish this by trimming out the areas before and after
stepdata = trimstepdata(stepdata, [tlim(2) inf]);
stepdata = trimstepdata(stepdata, [-inf tlim(1)]);