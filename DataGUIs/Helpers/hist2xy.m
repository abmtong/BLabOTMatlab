function out = hist2xy(ob)
%Gets the xy values from a @hist plot

%Default, use gco
if nargin < 1
    ob = gco;
end

%Make sure this object's a Patch (assumedly from @hist)
if ~isa(ob, 'matlab.graphics.primitive.Patch')
    warning('Pass the hist object, e.g. click then gco')
    return
end

%Get data from the patch values
vt = ob.Vertices;

%It's 5*n_bins + 1 verticies (each with x,y) each set of 5 is:
%{
[x_left     0
 x_left     0
 x_left     y_value
 x_right    y_value
 x_right    0
%}

%So let's just get the average of x_left and x_right and the y_value

xl = vt(3:5:end,1);
xr = vt(4:5:end,1);
yy = vt(3:5:end,2);

xx = (xl + xr) /2;

out = [xx(:) yy(:)];