function [ydiff, yfil, ycrop] = sgolaydiff(iny, sgparams)
%Applies Savitsky-Golay filtering/differentiation to the input trace iny using a sgfilter with paramters sgparams
% Outputs the filtered y', y, and unfiltered y (just cropped)

if nargin < 2
    sgparams = {1, 301}; %Seems to work for phage lo force - 301/2500 = 0.12s
end

%Design SG filter
[~, sgf] = sgolay(sgparams{:});



%Apply filter using @conv
yfil  = conv(iny, flipud(sgf(:,1)), 'same');

if sgparams{1} == 0 %0 rank doesn't generate diff matrix, so filter output from @diff instead
    ydiff = [0 conv(diff(yfil), flipud(sgf(:,1)),'same')];
    hwid = (size(sgf, 1) - 1) / 2;
else
    ydiff = conv(iny, flipud(sgf(:,2)), 'same');
    hwid = (size(sgf, 1) - 1) / 2;
end
%Crop start and end, because edge effects of @conv (and I don't have the transients for first derivative)
ycrop =   iny( 1 + hwid : end - hwid );
yfil  =  yfil( 1 + hwid : end - hwid );
ydiff = ydiff( 1 + hwid : end - hwid );