function out = lumKymoTrackV2(infp, inOpts)

%Options

%Basic options:
opts.color = [0 1 0]; %R, G, B multiplier for conversion to grayscale, i.e. [0 1 0] for just G, [2 1 0] = 2*R+G
opts.pxsz = 100; %Pixel size, nm
opts.debug = 0; %Debug plot

%Options for particle detection. better SNR = can lower some of these
opts.fil = 10; %Filter along time. Since each pixel is only like 0.2ms, 10ms = 50pts => fil = 25

%Options for position determination
opts.posmeth = 1; %See code below for options
opts.minsz = 3; %Minimum size for 'detected' point
opts.bkgmeth = 1; %Background correction method, see below for options
opts.dwlc = [50 900]; %XWLC for conversion to contour

opts.verbose = 1; %Plot output

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

if nargin < 1 || isempty(infp)
    [f, p] = uigetfile('*.mat', 'Mu', 'on');
    if ~p
        return
    end
    if ~iscell(f)
        f = {f};
    end
    out = cellfun(@(x) lumKymoTrackV2(fullfile(p,x), opts), f, 'Un', 0);
    out = [out{:}];
    return
end

%Load file
dat = load(infp);
fns = fieldnames(dat);
dat = dat.(fns{1});

%Get kymograph
imgraw = dat.apdimg;
tt = dat.apdT;
%Merge color together
img = imgraw(:,:,1)*opts.color(1) + imgraw(:,:,2)*opts.color(2) + imgraw(:,:,3)*opts.color(3);

%Crop kymograph, click edges of a rectangle (eg bottom-right + top-left corner) to crop
ssz = get(0,'ScreenSize');
ssz = ssz(3:4);
fg=figure('Name', 'Crop by clicking two corners of the crop rectangle', 'Position',[ ssz/4 ssz/2 ]);
surface(img, 'EdgeColor', 'none')
ax = gca;
ax.CLim(2) = ax.CLim(2) /2;
drawnow
gi = ginput(2);

xx = sort(gi(:,1));
yy = sort(gi(:,2));
img = img( floor(yy(1)):ceil(yy(2)), floor(xx(1)):ceil(xx(2)));
tt = tt(floor(xx(1)):ceil(xx(2))); %Time
close(fg);

%Filter a bit in time dim.
imgf = mat2cell(img, ones(1,size(img,1)), size(img,2));
imgf = cellfun(@(x) windowFilter(@mean, x, opts.fil, 1), imgf, 'Un', 0);
imgf = cell2mat(imgf);

%Background correct
switch opts.bkgmeth
    case 1 %Subtract a percentile mark, negative -> zero
        imgfb = imgf - prctile(imgf(:), 80); %Can edit 80 value
        imgfb = max(imgfb, 0);
end

len = size(imgf,2);
ext = nan(1,len);
yy = (1:size(imgf,1)) * opts.pxsz;
for i = 1:len
    %Detect position
    switch opts.posmeth
        case 1 %Background correct, take largest 'blob'
            %Grab this column of data
            tmp = imgfb(:,i)';
            tmpraw = img(:,i)';
            
            %Discretize and find runs of non-background data
            [in, me] = tra2ind(tmp > 0);
            dw = diff(in);
            dw = dw(me == 1);
            if isempty(dw)
                continue
            end            
            in1 = in([me == 1 false]);
            in2 = in([false me == 1]);
            
            %Get longest run
            [m, mi] = max(dw);
            if m < opts.minsz
                %Skip if too few pts
                continue
            end
            
            %Extract this portion
            newtmp = zeros(size(tmp));
%             %Use non-filtered raw data? Very noisy. Maybe usable with higher SNR
%             newtmp(in1(mi):in2(mi))=tmpraw(in1(mi):in2(mi));
            %Use filtered data?
            newtmp(in1(mi):in2(mi))=tmp(in1(mi):in2(mi));
            
            %Get centroid
            ext(i) = sum(yy .* newtmp)/sum(newtmp);
    end
end

%Get force: Downsample force trace and interpolate, I guess?
tall = dat.time;
fall = dat.force;
%Calculate downsample factor = 5^7/ mean(diff(tt));
dsampall = ceil( 5^7* mean(diff(tt)) /2 );
talld = windowFilter(@mean, tall, [], dsampall);
falld = windowFilter(@mean, fall, [], dsampall);
%Interpolate to tt
frc = interp1(talld, falld, tt, 'linear', nan);

%Calculate con from XWLC
con = ext ./ XWLC( frc, opts.dwlc(1), opts.dwlc(2)) / .34;

out.ext = ext;
out.time = tt;
out.frc = frc;
out.con = con;

[~, f, ~] = fileparts(infp);
out.file = f;

if opts.debug
    figure('Name', sprintf('lumKymoTrack debug for %s', f))
    hold on
    %Plot image
    surface(zeros(size(imgfb)),imgfb, 'EdgeColor', 'none')
    colormap jet
    %Plot trace over it
    plot(ext / opts.pxsz, 'r', 'LineWidth', 2)
end

if opts.verbose
    figure('Name', sprintf('lumKymoTrack results debug for %s', f))
    subplot(3,1,[1 2])
    hold on
    plot(out.time, -1*(out.con - max( out.con, [], 'omitnan' ))/1e3)
    xlabel('Time (s)')
    ylabel('Transcription (kb, rel.)')
    subplot(3,1,3)
    hold on
    plot(out.time, out.frc)
    xlabel('Time (s)')
    ylabel('Force (pN)')
end





