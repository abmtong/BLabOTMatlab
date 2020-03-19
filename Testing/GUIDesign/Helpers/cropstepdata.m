function stepdata = cropstepdata(stepdata, tl, keep)
%Crops the time, contour, force, extension fields in stepdata to be within crop

if nargin < 3
    keep = 1;
end

%Accomplish this by trimming out the areas before and after
stepdata = trimstepdata(stepdata, [tl(2) inf]);
stepdata = trimstepdata(stepdata, [-inf tl(1)]);

if ~keep
    stepdata = rmfield(stepdata, 'cut');
end