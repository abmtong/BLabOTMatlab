function out = ginput_fast(n)
%Same as ginput(n) but doesn't draw the crosshair, should be 'fast'?
% i.e., in some cases where ginput lags
% Eh don't handle multiple outputs. Just have out = [x; y]. No button type, either (third output)
% Note that this doesn't allow clicking across different figures, but @ginput doesn't do this either so vOv (limitation of @waitforbuttonpress)

%Changes the figure title to denote that ginput is happening (reverts it after)

%One point if no arg specified
if nargin < 1
    n = 1;
end

%This will be on one figure (gcf), so let's save this handle
fg = gcf;
% so we can update its name
oldnam = fg.Name;
out = nan(n,2);
str = '%s | ginput_fast: %d to go';
for i = 1:n
    %Deselect any tool. >>zoom on, zoom off should do this, but not elegant
    % Need to do this since if a tool is selected, ax.CurrentPoint does not update on click
    zoom on
    zoom off
    
    fg.Name = sprintf(str, oldnam, n-i+1);
    %Wait until the mouse is clicked, i.e. wfbp == 0
    % Else keyboard can advance past wfbp (and returns nonzero)
    while waitforbuttonpress
    end
    
    pt = get(gca, 'CurrentPoint');
    
    out(i,:) = pt([1 3]);
end

fg.Name = oldnam;