function out = ezSum_batch(inst, frchno, r, verbose)
%frchno is [frameno, channelno] that you want to use
%For every detected point on frame frno, do ezSum on it (just annotate by #? x,ypos?)

%Verbose option for ezSum, 0 = nothing, 1 = plots and gifs, 2 = gifs only
if nargin < 4
    verbose = 0;
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

%Create folder ezSum+Fr{Frame#} if gifs are to be made
dirnam = sprintf('ezSum_%s_Fr%03d', inputname(1), frchno(1));
if verbose
    if ~exist(dirnam, 'dir')
        mkdir( dirnam );
    end
end

out = cell(1,len);
dirnamcrop = dirnam(6:end); %Crop the name here so the parser is happy with how it's used in parfor
parfor i = 1:len %Lets parfor for speed
    %Get centroid
    cen = rprops(i).cen;
    
    %Do ezSum
    tmpres = ezSum(inst, [round(cen) r], sprintf('%s%sEzSum_Spot%03d', dirnamcrop, filesep, i  ) , verbose);
    %Add metadata?
    
    out{i} = tmpres;
end

%Concatenate
out = [out{:}];

%Add isframed if it was used
if length(frchno) == 3
    isfc = num2cell(isframed);
    [out.isframed] = deal(isfc{:});
end

ezSum_plot(out, frs, sprintf('Data: %s, %s', inputname(1), optstr ));

