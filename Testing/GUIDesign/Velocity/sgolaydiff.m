function [dinyF, inyF, iny] = sgolaydiff(iny, sgparams)

if nargin < 2
    sgparams = {1, 133};
end

[~, sgf] = sgolay(sgparams{:});

%Filter
inyF  = conv(iny, flipud(sgf(:,1)), 'same'); %Might make more sense to xcorr(u, v) instead of conv(u, flipud(v)), but is the same
if sgparams{1} == 0 %0 rank doesn't generate d matrix
    dinyF = [0 conv(diff(inyF), flipud(sgf(:,1)),'same')];
    fwid = 2*(size(sgf, 1) - 1) / 2;
else
    dinyF = conv(iny, flipud(sgf(:,2)), 'same');
    fwid = (size(sgf, 1) - 1) / 2;
end
%Crop start and end, because edge effects of @conv (and I don't have the transients for first derivative)
iny =     iny( 1 + fwid : end - fwid );
inyF =   inyF( 1 + fwid : end - fwid );
dinyF = dinyF( 1 + fwid : end - fwid ); %convert rate from bp/pt to bp/s

%Make