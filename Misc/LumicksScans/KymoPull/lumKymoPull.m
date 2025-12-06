function out = lumKymoPull(infp, inOpts)
%Extract the single-fluorophore counts from a force-extension pull
% e.g. unwrapping a fluorescent nucleosome with a pulling curve. Since Lumicks doesn't have symmetric trap movement, the fluorophore moves with pulling.
% Could be edited to handle force feedback, too.

opts.fil = 20; %Filter cts in time by this many pts. Since t_px is ~.08ms (!), lets up this at least to 1ms or so
opts.cols = [1 1 1]; %R, G, B t/f

opts.distancefudge = 1; %Multiplier to pixel size, if Lumicks' calibration is off
opts.extsource = 2; %Extension to use, =1 for piezo or =2 for camera
opts.rbead = [500 500]; %Bead radii, [A, B] where A is movable

opts.flwid = 250; %nm to integrate fluorophore spot over. Actually uses an integer multiple of pixel size, which is usually 100nm

%Plotting
opts.debug = 1; %Show debug plot, of bead position + fluorophore integration window
opts.verbose = 1; %Plot F-t and Fluor-t
opts.save = 1; %Save new file with the results as apd1/2/3 field. 

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

if opts.fil > 1
    %Filter img field. All npx*3 rows...
    for i = 1:size(img, 1);
        for j = 1:3,
            img(i,:,j) = windowFilter(@mean, img(i,:,j), opts.fil, 1);
        end
    end
end


% %Combine to grayscale image
% % Auto-contrast each color and add together
% imgbw = zeros(size(img,1), size(img,2));
% if opts.cols(1);
%     imgbw = imgbw + img(:,:,1) / max(max(img(:,:,1)));
% end
% if opts.cols(2);
%     imgbw = imgbw + img(:,:,2) / max(max(img(:,:,2)));
% end
% if opts.cols(3);
%     imgbw = imgbw + img(:,:,3) / max(max(img(:,:,3)));
% end
% % imgbw = imgbw/ prctile(imgbw(:), 95);

%Plot. Downsampling seems unnecessary? Might be in the future, though.
ssz = get(0, 'ScreenSize');
ssz = ssz(3:4)*.75;
fg = figure('Position', [ssz/8 ssz]); hold on
surface( zeros(size(img, 1), size(img,2)) , img, 'EdgeColor', 'none'); axis tight
%Do some contrast adjustment, trim upper CLim
ax = gca;
ax.CLim = ax.CLim .* [0 0.80];

%Ask user to choose 3 points: Fixed bead, Moving bead, Fluorophore
fg.Name = 'Pick a center of the FIXED bead';
g1 = ginput(1);
fg.Name = 'Pick a center of the MOVABLE bead';
g2 = ginput(1);
fg.Name = 'Pick a center of the FLUOROPHORE';
g3 = ginput(1);
fg.Name = '';

%Get data
extax = -dat.forceAX/dat.cal.AX.k; %Negative, so negate to make positive
extbx = dat.forceBX/dat.cal.BX.k; %Positive
tim = dat.time;
switch opts.extsource
    case 1 %Piezo Distance
        ext = dat.extension;
    otherwise %Camera. These are stored in 'offset' file
        dy = dat.off.AX;
        dx = dat.off.TX;
        %Interp to extension time units
        ext = interp1(dx, dy, tim, 'linear', 'extrap');
end
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
pxsz = dat.meta.pxsznm * opts.distancefudge; %Pixel size, nm/px
tposbpx = gpx(1) - gextbx(1) / pxsz;
tposapx = gpx(2) + gextax(2) / pxsz;

%Create locations in px via interp. Filtered only? Or raw?
pxtposb = ones(size(timF)) * tposbpx;
pxtposa = tposapx + (tposF - gtpos(2))/pxsz;
pxbeadb = pxtposb + extaxF/pxsz;
pxbeada = pxtposa - extbxF/pxsz;

%Subtract bead radii
pxextb = pxbeadb + opts.rbead(2)/pxsz;
pxexta = pxbeada - opts.rbead(1)/pxsz;
pxext = pxexta - pxextb;

%Find fluorophore location. Assume this is always a pct. of the tether length
flupct =  (gpx(3)- interp1(timF,pxextb,gt(3))) / interp1(timF,pxext,gt(3));
pxflupos = pxextb + pxext * flupct;
%Integrate over this region... make it a set number of pixels?
pxintwid = ceil(opts.flwid / pxsz); %Half-width, so integrate over pxflupos(i) - pxintwid to +pxintwid

len = min( size(img,2), length(pxflupos) ); %Slightly different lengths... ignore? like 10956 vs 10949. Or interp one into the other.

hei = size(img,1);
out = zeros(len,3); %R G B
for i = 1:len
    %Get region. Coerce to within range
    mid = round(pxflupos(i));
    lo = max( mid - pxintwid, 1);
    hi = min( mid + pxintwid, hei);
    
    out(i,:) = squeeze(sum( img(lo:hi, i, :), 1) );
end


%Some custom 'integrator' ? That handles fractional pixels


%Plot debug
if opts.debug
    %Plot markers of three points
    plot(g(:,1), g(:,2) , 'o')
    
    %Plot lines of trap positions and bead centers
    xx = 1:length(pxtposb);
    plot(xx, pxtposb, 'LineWidth', 1);
    plot(xx, pxtposa, 'LineWidth', 1);
    plot(xx, pxbeadb, 'LineWidth', 1);
    plot(xx, pxbeada, 'LineWidth', 1);
    plot(xx, pxflupos, 'LineWidth', 1);
    plot(xx, pxflupos-pxintwid, 'LineWidth', 1);
    plot(xx, pxflupos+pxintwid, 'LineWidth', 1);
    
    %Fluorophore center and integration width
    
else
    close(fg);
end

if opts.verbose
    
    
end


%Resave, adding these as 'apd1/2/3' fields?

newp = 'LumKymoPull';
[p, f, e] = fileparts(infp);
if ~isdir(fullfile(p, newp))
    mkdir(fullfile(p, newp))
end
dat = rmfield(dat, 'apdimg');
dat.apd1 = out(:,2)'; %G
dat.apd2 = out(:,1)'; %R
dat.apd3 = out(:,3)'; %B

ContourData = dat; %#ok<NASGU>
save( fullfile(p, newp, [f e]), 'ContourData');


















