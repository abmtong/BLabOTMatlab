function out = vthresh(dat, sgp, thr)

if nargin < 2 || isempty(sgp)
    sgp = {1 51};
end

if nargin < 3 || isempty(thr)
    thr = 'adaptive';
end

[vel, datfil, datcrp] = sgolaydiff(dat, sgp);

%Make velocity threshold: Either use the 
if strcmp(thr, 'adaptive')
    %Estimate noise of velocity by MAD, take 3sd
    vmad = mad(vel, 1) /2 / erfinv(0.5); %MAD to SD scaling
    thr = vmad * 3; %Take anything outside 3sd, say
end

len = length(dat);
ki = abs(vel) > thr;

%Naive: Flat sections
%Find transitions: find changes in ki
ind = [1 find( diff(ki) ) len];
mea = ind2mea(ind, dat);
tra = ind2tra(ind, mea);

%Find start and ends
indSta = find( diff([false ki false]) == 1 );
indEnd = find( diff([false ki false]) == -1 );

%Fit sections to lines
outx = zeros(2,length(indSta));
outy = zeros(2,length(indSta));
for i = 1:length(indSta);
    tmpx = [indSta(i) indEnd(i)-1];
    tmp = datcrp( tmpx(1):tmpx(2) );
    pf = polyfit( 1:length(tmp), tmp, 1 );
    %Extract position of start and end pt.
    outx(:,i) = tmpx;
    outy(:,i) = polyval(pf, [1 length(tmp)]);
end
outx = outx(:)';
outy = outy(:)';

figure, hold on
plot(datcrp, 'Color', [0.7 0.7 0.7])
plot(datfil, 'Color', 'b')
%Fit staircase
% plot(tra, 'Color', 'r')
plot(outx, outy, 'Color', 'g');

%Plot just steps
for i = 1:2:length(outx)-1
    plot(outx([i i+1]), outy([i i+1]), 'r', 'LineWidth', 2)
end

%Plot verticals on start/ends
% yy = [min(dat) max(dat)];
% for i = 1:length(indSta)
%     line(indSta(i)*[1 1], yy, 'Color', [0 1 0])
%     line(indEnd(i)*[1 1], yy, 'Color', [1 0 0])
% end

%Debug: Velocity graph
% vscal = prctile(abs(dat), 99) / prctile(abs(vel), 90) ;
% 
% plot(vel * vscal) %Velocity
% plot([len 0 0 len], thr * vscal * [1 1 -1 -1]); %Threshold


