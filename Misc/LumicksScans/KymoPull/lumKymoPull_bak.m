function out = lumKymoPull_bak(infp, inOpts)
%Extract the single-fluorophore counts from a force-extension pull
% e.g. unwrapping a fluorescent nucleosome with a pulling curve. Since Lumicks doesn't have symmetric trap movement, the fluorophore moves with pulling.
% Could be edited to handle force feedback, too.
%_bak: This was with calculating px per nm. It should be 100nm/px, though, so assume that now.

opts.debug = 1; %Show debug plot, of bead position + fluorophore integration window
opts.foo = 'bar';
opts.flwid = 250; %nm to integrate fluorophore spot over
opts.cols = [1 1 0]; %R, G, B t/f

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Handle batch
if nargin < 1 || isempty(infp)
    [f, p] = uigetfile('*.mat', 'Mu', 'on');
    if ~p
        return
    end
    if ~iscell(f)
        f = {f};
    end
    mfp = mfilename();
    fh = str2func(mfp);
    out = cellfun(@(x) fh(fullfile(p,x), opts), f, 'Un', 0);
    out = [out{:}];
    return
end

%Load
dat = load(infp, 'ContourData');
dat = dat.ContourData;

%Get kymograph
img = double(dat.apdimg);
imgT = dat.apdT;

%Combine to grayscale image
% Auto-contrast each color and add together
imgbw = zeros(size(img,1), size(img,2));
if opts.cols(1);
    imgbw = imgbw + img(:,:,1) / max(max(img(:,:,1)));
end
if opts.cols(2);
    imgbw = imgbw + img(:,:,2) / max(max(img(:,:,2)));
end
if opts.cols(3);
    imgbw = imgbw + img(:,:,3) / max(max(img(:,:,3)));
end
imgbw = imgbw/ prctile(imgbw(:), 95);

%Plot. Downsampling seems unnecessary? Might be in the future, though.
ssz = get(0, 'ScreenSize');
ssz = ssz(3:4)*.75;
fg = figure('Position', [ssz/4 ssz]); hold on
surface(imgbw, 'EdgeColor', 'none'); colormap jet, axis tight

%Ask user to choose 3 points: Fixed bead, Moving bead, Fluorophore
fg.Name = 'Pick a center of the FIXED bead';
g1 = ginput(1);
fg.Name = 'Pick a center of the MOVABLE bead';
g2 = ginput(1);
fg.Name = 'Pick a center of the FLUOROPHORE';
g3 = ginput(1);

%Get data
ext = dat.extension;
extax = -dat.forceAX/dat.cal.AX.k; %Negative, so negate to make positive
extbx = dat.forceBX/dat.cal.BX.k; %Positive
tpos = ext + extax + extbx;

%Downsample data to match apdT
dsamp = round( length( dat.extension) / length(dat.apdT) ); %Use round bc its prooobably near-integer
extF = windowFilter(@mean, ext, [], dsamp);
extaxF = windowFilter(@mean, extax, [], dsamp);
extbxF = windowFilter(@mean, extbx, [], dsamp);
tposF = windowFilter(@mean, tpos, [], dsamp);
timF = windowFilter(@mean, dat.time, [], dsamp);

%Process
g = [g1; g2; g3]; %time(:), px(:)
gt = interp1( 1:length(imgT), imgT, g(:,1) ); %Timept of ginput clicks
gpx = g(:,2);
%Get force/extension values at these clicks
gext = interp1( timF, extF, gt ); 
gextax = interp1( timF, extaxF, gt ); 
gextbx = interp1( timF, extbxF, gt ); 
gtpos = interp1( timF, tposF, gt ); 
%Find two things: Position of fixed trap in px, and px/nm conversion
% This is a system of two equations:
%   At first point, trap pos (px) + extbx/pxsz = g1(2)
%   At second point, trap pos (px) + (extbx+ext)/pxsz = g2(2)
% Simple solve of this system of equations
pxsz = (gextbx(2) + gext(2) - gextbx(1) ) / (gpx(2) - gpx(1)); %Pixel size, nm/px
tposbpx = gpx(1) - gextbx(1) / pxsz;

%Create locations in px via interp. Filtered only? Or raw?
pxtposb = ones(size(timF)) * tposbpx;
pxtposa = pxtposb + tposF/pxsz;
pxbeadb = pxtposb + extaxF/pxsz;
pxbeada = pxtposa - extbxF/pxsz;

%Find fluorophore location. Assume this is always a pct. of the tether length
flupct =  (gpx(3)- interp1(timF,pxbeadb,gt(3))) / (gext(3)/pxsz);
pxflupos = pxbeadb + extF * flupct / pxsz;
%Integrate over this region... make it a set number of pixels?
pxintwid = ceil(opts.flwid / pxsz); %Half-width, so integrate over pxflupos(i) - pxintwid to +pxintwid




%Some custom 'integrator' ? That handles fractional pixels


%Plot debug
if opts.debug
    %Plot markers of three points
    plot(g(:,1), g(:,2) , 'o')
    
    %Plot lines of trap positions and bead centers
    xx = 1:length(pxtposb);
    plot(xx, pxtposb);
    plot(xx, pxtposa);
    plot(xx, pxbeadb);
    plot(xx, pxbeada);
    %Fluorophore center and integration width
    
else
    close(fg);
end



%Get trap pos and bead deflection at these timepts





















