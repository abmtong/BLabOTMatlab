function rot2prot(inrot)
%inrot is in rotations
%Select the highest number of full rotations


%First, align peak to 0.5 ish, so when we cut rotations, its during a -peak
xx = (0:360)/360;
yy = histcounts(mod(inrot, 1), xx);
[~, mi] = max(yy);
inrot = inrot - xx(mi)+.5; %Aligns a peak at 0.5

%Calculate time of first crossings of this guy
rmin = ceil(min(inrot));
rmax = floor(max(inrot));

inrf = smooth(inrot, 100);
%Dont necessarily know what dir this goes [probably hyd, but w/e], so find nearest
[~, mini] = min(abs(inrf - rmin));
[~, maxi] = min(abs(inrf - rmax));
%Filter down, find first crossings
t = sort([mini, maxi]);

%Crop to this area
rc = inrot(t(1):t(2));

%Method 1: align rotations
%Find integer crossings
fi = rmin+1:rmax-1;

inds = arrayfun(@(x)find(rc > x, 1, 'first'), fi);

inds = [1 inds length(rc)];
%Divvy up
rsnip = arrayfun(@(x,y,z) rc(x:y)-z, inds(1:end-1), inds(2:end), rmin:rmax-1, 'un', 0);

%Plot together
%Is this smoothable? Do by taking median pt. (average pt?) in a range
xx = cellfun(@(x) (0:length(x)-1)/length(x),rsnip, 'un', 0);
figure, hold on, cellfun(@plot, xx, rsnip)

x = [xx{:}];
y = [rsnip{:}];

npts = 1e3;

ymean = zeros(1,npts);
ymedi = zeros(1,npts);
for i = 1:npts
    %in the region [i-1, i)/npts, extract pts + take mean/median
    tmp = y( x >= (i-1)/npts & x < i/npts);
    ymean(i) = mean(tmp);
    ymedi(i) = median(tmp);
end
xy = (0:npts-1)/npts;
plot(xy, ymean, 'LineWidth', 2, 'Color', 'k')
plot(xy, ymedi, 'LineWidth', 2, 'Color', 'r')


%Method 2: measure v(x) with sgolay
%Derive by first order S-G filters
sgwid = 21;
[v, ~, ysg] = sgolaydiff(rc, {1 sgwid});

%Bin v by y pos
bsz = 2;
xb = (0:bsz:360) /360;
len = length(xb)-1;
y2 = zeros(1,len);

for i = 1:len
    y2(i) = mean( v( mod(ysg,1) >= xb(i) & mod(ysg,1) < xb(i+1)) );
end
x = xb(1:end-1)+bsz/2/360;
figure, plot(x,y2)



