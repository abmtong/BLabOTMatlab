function fitRise_plotapdv(inst, ncs)
%Input: Data struct that has been sent through fitRise and getSpotPos
% i.e., has fields fitRise.dt (frame delay) and fitRise.cenapdv (centroid, APDV axis)

%Which nuclear cycles to plot
if nargin < 2
    ncs = 12:14;
end

%Options
binsz = 0.05;
% conv = 4300/15; % bp/s = conv / frames
conv = 4300/15 /1e3 *60; % kb/min = conv / frames

%Crop to NC range
% Should probably make nc a field...
len = length(inst);
nc = cell(1,len);
for i = 1:len
    nc{i} = (-length( inst(i).fitRise ):-1) + 15; %Last cycle is nc14 always
end
fitr = [inst.fitRise]; %Grab each fitRise struct
nc = [nc{:}]; %NC for each fitRise struct
ki = arrayfun( @(x) any(ncs == x), nc );
fitr = fitr(ki);

%Get data from fitRise structs
ap = cellfun(@(y) arrayfun(@(x) x.cenapdv(1), y), fitr, 'Un', 0);
df = cellfun(@(x) [x.dt], fitr, 'Un', 0);

%Collapse ap, df
apall = [ap{:}];
dfall = [df{:}];

%Bin by ap dir
xedges = 0:binsz:1;
xcent = xedges(1:end-1)+binsz/2;

binind = discretize(apall, xedges); %Could also do like ceil( ap / binsz) but whatevs


ycell = cell(1, length(xcent));
ymean = nan(1, length(xcent));
ysem = nan(1, length(xcent));
for i = 1:length(xcent)
    tmp = dfall(  binind == i );
    
    %Lets kill nonnegatives and NaN
    tmp = tmp(tmp > 0 & ~isnan(tmp));
    
    ycell{i} = tmp;
    %Replaceable in one line with ycell = cellfun(@(x) df( binind == x), num2cell(1:length(xcent)), 'Un', 0);
    
    if ~isempty(tmp);
        ymean(i) = mean(tmp);
        ysem(i) = std(tmp) / sqrt( length( tmp));
    end
end

%Convert ymean, ysem to bp/s
figure, 
ax1= subplot(2,1,1);
errorbar(xcent, conv./ymean, (conv ./ ymean) .* (ysem ./ ymean) )
xlabel('A-P position (A=1)')
ylabel('Transcription speed (kb/min)')

% %Scatter raw data, colored by data 
% subplot(2,1,2)
% hold on
% for i = 1:length(ap)
%     scatter(ap{i}, df{i})
% end
% EH this isnt helpful

%N plot
ax2 = subplot(2,1,2);
bar(xcent, cellfun(@length, ycell))
title('N')

linkaxes([ax1 ax2], 'x')








