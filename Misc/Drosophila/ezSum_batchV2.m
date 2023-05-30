function out = ezSum_batchV2(inst, frchno, r, verbose, name)
%frchno is [frameno, channelno] that you want to use
%For every detected point on frame frno, do ezSum on it (just annotate by #? x,ypos?)

%V2: ROI follows the spot

%Verbose option for ezSum, 0 = nothing, 1 = plots and gifs, 2 = gifs only
if nargin < 4
    verbose = 0;
end

%Name for gif output
if nargin < 5
    name = inputname(1);
end

%Find the frame and channel to get spot detection from
frs = [inst.frame];
chs = [inst.ch];

%Dilate to merge adjacent circles, if needed, when merging spot detections
ndil = -1;

%Create options string
frchstr = sprintf('[ %s]', sprintf('%d ', frchno)); %frchno -> [95 100 3]
optstr = sprintf('Frames: %s, R: %d, dilate: %d', frchstr, r, ndil);

if length(frchno) == 2 %One frame, one channel
    ind = find(frs == frchno(1) & chs == frchno(2), 1, 'first');
    rprops = inst(ind).rprops;
    len = length(rprops);
    
    %Create newlbl, for later in case this syntax is still used
    [~, newlbl] = mergebdys( {rprops.bdy}, ndil );
    
elseif length(frchno) >= 3 %Range of frames
    %Grab this range frames on the channel
    if length(frchno) == 3
        %If frchno(3) == 3, use both channels (i.e., don't select for channel
        if frchno(3) == 3 %Just find the right frames
            ki = frs >= frchno(1) & frs <= frchno(2);
        else %Right frames and channels
            ki = frs >= frchno(1) & frs <= frchno(2) & chs == frchno(3) ;
        end
    elseif length(frchno) == 4 % [Ch1 frame 1, Ch1 frame end, Ch2 frame 1, Ch2 frame end]
        ki = (frs >= frchno(1) & frs <= frchno(2) & chs == 1 )  | (frs >= frchno(3) & frs <= frchno(4) & chs == 2 ) ;
    end
    %Get these frames 
    instcrp = inst(ki);
    %Let's merge the ID'd regions together
    rps = [instcrp.rprops];

    [newbdys, newlbl] = mergebdys( {rps.bdy}, ndil ); %Note that there's a dilate in mergebdys, so maybe fiddle there
    
    %Get centroids of this image
    newrps = regionprops(newlbl, 'Centroid', 'BoundingBox');
    
    %Maybe check if the radius is big enough to contain this image
    % Or instead of taking it from the Centroid, just take the middle of the bbox
    len = length(newrps);
    cens = cell(1,len);
    rads = nan(1,len); %BBox avg radii
    isframed = true(1,len); %Count how many might have issues if we do bbox centering
    for i = 1:len
        %Method 1 : Just take centroid
        cens{i} = newrps(i).Centroid;
        
%         %Method 2: Middle of bbox
%         cens{i} = round( newrps(i).BoundingBox(1:2) + newrps(i).BoundingBox(3:4)/2 );
        

        %Save radius
        rads(i) = max(newrps(i).BoundingBox(3:4))/2;
        
        %Check that the supplied radius is big enough
        if max(newrps(i).BoundingBox(3:4)) > r*2+1
            isframed(i) = false;
%             warning('Region %d (centroid %d, %d) might be too big')
        end
    end
    
    %Print stats on 'box radii'
    radnan = rads( ~isnan(rads) );
    fprintf('Average particle radius of %0.2f, quartiles [%0.2f %0.2f %0.2f %0.2f %0.2f]\n', median(radnan, 'omitnan'), prctile(radnan, 0), prctile(radnan, 25), prctile(radnan, 50), prctile(radnan, 75), prctile(radnan, 100))
    if any(~isframed)
        warning('Some regions (%d/%d) may be too big for the current box size', sum(~isframed), len)
    end
    
    %Rename to rprops, just need centroid field
    rprops = struct( 'cen', cens );
    
    %Plot boundaries to make sure we're 'okay'
    %Sum intensities across the images; assume intensity count is small enough for uint16
    imgsum = instcrp(1).img;
    for i = 2:length(instcrp)
        imgsum = imgsum + instcrp(i).img;
    end
    
    %And plot detection results
    figure('Name', sprintf('ezSum_batch: Check Spot Separation: %s', optstr) )
    surface( zeros(size(imgsum)), imgsum, 'EdgeColor', 'none' )
    colormap gray
    axis tight
    hold on
    %Draw the region boundaries over it
    for i = 1:len
        plot( newbdys{i}(:,2) , newbdys{i}(:,1), 'LineWidth', 1 )
    end
    drawnow
else
    error('Cant parse frchno, exiting')
end

%V2: Now back-reference the end summed region vs the spots
%Create storage for the centroids, a nfr x length(cens) struct
nfr = length(frs)/2; %Sloppy but works, assumes 2 chs
trackcens = nan( len, nfr, 2 ); % spot, frame, x,y pos

%Precalculate the label images. Use parfor for speed
%Create lblimg field so parfor is happy
inst(1).lblimg = [];
parfor i = 1:length(inst)
    %Make sure there's at least some rprops, else rprops.bdy fails
    if ~isempty(inst(i).rprops)
        inst(i).lblimg = bdy2img( {inst(i).rprops.bdy}, size(inst(i).img) );
    else %If no rprops, just default to zeros
        inst(i).lblimg = zeros(size(inst(i).img));
    end
end

%For every spot in newlbl
tfkeep = true(1,len); %Keep track if we want to keep particles
%Minimum connected centroids, to ignore blips
% Calculate dependent on the number of frames in frchno
% mincens = 5;
mincens = min(frchno(4) - frchno(3), frchno(2) - frchno(1) ) /2 ;
mincens = max( round(mincens), 2); %Need at least 2 for interp1
for i = 1:len
    %Find a corresponding spot for each frame
    for j = 1:nfr
        %Check both channels
        tmpcens = nan(2,2); %Centroid [x,y channel 1; x,y channel 2]
        for k = 1:2
            %Get this frame and channel
            tmp = inst( frs == frs(j) & k == chs );
            
            %Get this frame's label image
            tmplbl = tmp.lblimg;
            
            %Check if any of the spots overlap the current spot (newlbl == i)
            lblcrp = tmplbl(newlbl == i);
            lblcrp = unique(lblcrp);
            
            %Remove zero from lblcrp
            lblcrp(lblcrp == 0) = [];
            
            %If there's only one spot that overlaps, save it
            if length(lblcrp) == 1
                %Then fetch this centroid and save as tmpcens
                tmpcens(1,:) = tmp.rprops(lblcrp).cen;
            end %Otherwise, there's none/multiple spots, leave as nan
        end
        
        %Merge tmpcens together (i.e., take center of red + grn spot) and save
        trackcens(i,j,:) = mean( tmpcens, 1, 'omitnan' );
    end
    
    %Interpolate the missing frames
    %Get data
    intx = trackcens(i,:,1);
    inty = trackcens(i,:,2);
    intf = 1:nfr;
    %Remove nans
    intf = intf(~isnan(inty));
    intx = intx(~isnan(inty));
    inty = inty(~isnan(inty));
    
    %Set some minimum number of real detected centroids. Absolute minimum is 2, for interp1 to work
    if length(intx) < mincens
        %And reject if too few
        tfkeep(i) = false;
        continue
    end
    
    %Interp missing data
    intxq = interp1(intf, intx, 1:nfr, 'nearest', 'extrap');
    intyq = interp1(intf, inty, 1:nfr, 'nearest', 'extrap');
    
    %Save
    trackcens(i,:,1) = intxq;
    trackcens(i,:,2) = intyq;
end

%Note rejection
if ~all(tfkeep)
    warning('Rejected %d/%d spots due to too few overlapping spots (%d)', sum(~tfkeep), length(tfkeep), mincens )
end

%Apply cropping
trackcens = trackcens(tfkeep, :, :);
len = sum(tfkeep);

%Debug: Plot trackcens' findings, on the same img
for i = 1:len
    %Plot a line that shows the spot loc over time
    plot3(trackcens(i,:,1), trackcens(i,:,2), 1:nfr );
end %Some weirdness outside the cycle of interest (naturally) but works for what we care about


%Create folder ezSum+Fr{Frame#} if gifs are to be made
dirnam = sprintf('ezSum_%s_Fr%03d_%s', name, frchno(1), datestr(now, 'YYmmDDHHMMSS'));
if verbose
    if ~exist(dirnam, 'dir')
        mkdir( dirnam );
    end
end

out = cell(1,len);
dirnamcrop = dirnam(6:end); %Crop the name here so the parser is happy with how it's used in parfor
parfor i = 1:len %Lets parfor for speed
    %Create centroid vector
    cens = squeeze(trackcens(i,:,:));
    cens = repmat(cens, 2, 1);
    
    %Do ezSum
    tmpres = ezSumV2(inst, cens, r, sprintf('%s%sEzSum_Spot%03d', dirnamcrop, filesep, i  ) , verbose);
    out{i} = tmpres;
end

%Concatenate
out = [out{:}];

%Add isframed if it was used
if length(frchno) == 3
    isfc = num2cell(isframed);
    [out.isframed] = deal(isfc{:});
end

ezSum_plot(out, frs, sprintf('Data: %s, %s', name, optstr ));

