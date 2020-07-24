function [dinyF, inyF, inyCr] = sgolaydiff(iny, sgparams)
%Applies sgolay filtering/differentiation to iny using a sgfilter with paramters sgparams
% Outputs the filtered y', y, and unfiltered y (just cropped)
% Adopted from Ronen's polymerase pausing code

if nargin < 2
    sgparams = {1, 133}; %Seems to be ok for phage lo force - different from default in @vdist...
end

%get SGFilter
[~, sgf] = sgolay(sgparams{:});

%Apply filter using @conv
inyF  = conv(iny, flipud(sgf(:,1)), 'same');
%Might make more sense to xcorr(u, v) instead of conv(u, flipud(v)), but is the same.
% Cropping later becomes iny( length(iny) + 1 : end - fwid - 1 );

if sgparams{1} == 0 %0 rank doesn't generate diff matrix, so filter output from @diff instead
    dinyF = [0 conv(diff(inyF), flipud(sgf(:,1)),'same')];
    fwid = 2*(size(sgf, 1) - 1) / 2; %idk why we crop more in this case. seems wrong? but I'll never use this anyway
    warning('0 rank filter width might be wrong? see @sgolaydiff')
else
    dinyF = conv(iny, flipud(sgf(:,2)), 'same');
    fwid = (size(sgf, 1) - 1) / 2; %= size(sgf, 1) == sgparams{2}
end
%Crop start and end, because edge effects of @conv (and I don't have the transients for first derivative)
inyCr =   iny( 1 + fwid : end - fwid);
inyF =   inyF( 1 + fwid : end - fwid);
dinyF = dinyF( 1 + fwid : end - fwid);