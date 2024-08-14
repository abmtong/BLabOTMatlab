function out = ezDroAP(midimg, inOpts)
%Calculates the AP (Anterior-Posterior) location from a 'middle' 

%Input: image from a 'mid-embryo' scan, MCherry channel (channel 2 / file _01)
% Usually \RawDynamicsData\[date]\[Experiment name]\Mid_Mid_RAW_ch01.tif

opts.blurwid = 5; %Gaussian filter width
opts.verbose = 1; %Plot A/P locs
opts.debug = 0; %Debug plots
opts.edgesmooth = 50; %Smooth the edges with imopen(img, strel(disk, edgesmooth))
                      % Some embryos have a little nub sticking out, let's smooth that over
opts.askapdv = 0; %Prompt the user about APDV placement

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Convert to double
im = double(midimg);

%Blur a bit to result in a smoother embryo edge (mostly unnecessary?)
imf = imgaussfilt(im, opts.blurwid); %Garcia used 2um/img px size, so 2/.212 = 9 ish. 

%Convert to bw
imbw = im2bw(imf, graythresh(im));

%Fill holes. Or fill holes before?
imbw = imfill(imbw, 'holes');


%Calculate region props
[bwb, lbl] = bwboundaries(imbw);
rps = regionprops(lbl, 'Centroid', 'Area', 'Orientation');

if opts.debug
    figure, surface(im, 'EdgeColor', 'none')
    hold on
    plot(bwb{1}(:,2),bwb{1}(:,1))
end

%There should only be one region found, but if there's more, get largest area
ar = [rps.Area];
[~, mi] = max(ar);
%Make sure this is ~10x larger than any other? eh
% bdy = bwb{mi};
rp = rps(mi);

%Make this the only region
imbw = lbl == mi;

%And sand off any nubs
imbw = imopen( imbw, strel('disk', opts.edgesmooth ) );

%Rotate image so major axis is on X axis
imro = imrotate(imbw, -rp.Orientation, 'nearest', 'crop');

%Recalc rprops to get 'extrema'
rpr = regionprops(imro, 'Extrema');
if length(rpr) > 1
    warning('Found multiple regions after rotation, check')
end

%From extrema, take the center in all 4 directions and use these as A/P and D/V locs
xt = rpr.Extrema;
apdv = { (xt(3,:) + xt(4,:))/2 (xt(7,:) + xt(8,:))/2 (xt(1,:) + xt(2,:))/2 (xt(5,:) + xt(6,:))/2 };

%Guess A/P and D/V by heuristic: one side is more 'boxy' than the other, so the line at 1/2 vol should be closer to that side

%So guess AP
apvolln = cumsum(sum(imro, 1));
%Find pt that divides the volume in two: from last pt before cumsum(end)/2 and linearly interpolate
%Lets subtract end/2, so look for zero crossing
apvolln = apvolln - apvolln(end)/2;
indlast = find(apvolln < 0, 1, 'last');
apcrp = apvolln(indlast:indlast+1);
aphalf = indlast - apvolln(indlast) / diff(apcrp);
%And find which pt this sits closer to. This should be the posterior side.
da = abs(aphalf - apdv{1}(1));
dp = abs(apdv{2}(1) - aphalf);
%If it is closer to what is labeled as the anterior side, then swap
if dp > da
    apdv([1 2]) = apdv([2 1]);
end %Otherwise, current ordering is correct

%And guess DV
dvvolln = cumsum(sum(imro, 2));
%Find pt that divides the volume in two
%Lets subtract end/2, so look for zero crossing
dvvolln = dvvolln - dvvolln(end)/2;
indlast = find(dvvolln < 0, 1, 'last');
dvcrp = dvvolln(indlast:indlast+1);
dvhalf = indlast - dvvolln(indlast) / diff(dvcrp);
%for D/V, it should be closer to the V side
dd = dvhalf - apdv{3}(2);
dv = apdv{4}(2) - dvhalf;
if dv > dd
    apdv([3 4]) = apdv([4 3]);
end

%Rotate APDV back to original coords
rotmtx = [cosd(rp.Orientation), -sind(rp.Orientation); sind(rp.Orientation) cosd(rp.Orientation)];
apdv = cellfun(@(x) (x - size(im)/2) * rotmtx + size(im)/2, apdv, 'Un', 0);

if opts.verbose
    figure, surface(zeros(size(im)), im, 'EdgeColor', 'none')
    hold on
    
    txt = 'APDV';
    txts = cell(1,4);
    for i = 1:4
        plot(apdv{i}(1), apdv{i}(2),'o', 'LineWidth',2,'MarkerSize', 5)
        txts{i} = text(apdv{i}(1), apdv{i}(2), txt(i), 'Color', [1 1 1], 'FontSize', 14, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
    end
    colormap jet
    axis tight
    
    %Pop a text box asking if A/P and D/V are assigned correctly
    if opts.askapdv
        idl = inputdlg({'If A/P are swapped, enter 1, else leave blank' 'If D/V are swapped, enter 1, else leave blank'},'Are A/P and D/V assigned correctly?',1) ;
        if ~isempty(idl) %If cancel is pressed, ignore
            if idl{1}
                apdv([1 2]) = apdv([2 1]);
                txts{2}.String = 'A';
                txts{1}.String = 'P';
            end
            if idl{2}
                apdv([3 4]) = apdv([4 3]);
                txts{4}.String = 'D';
                txts{3}.String = 'V';
            end
        end
    else
        fprintf('Skipping APDV prompt, check with ezDroAP_check\n')
    end
end



out = apdv;















