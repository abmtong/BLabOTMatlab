function out = chopnpspec(ext, frc, wid)
%

if nargin < 3
    wid = 1e5; %pts
end

Fs=1e5;

%Chop
len = length(ext);
segind = (0:floor( (len)/wid)) * wid + 1;
hei = length(segind)-1;

datcrp = cell(2,hei); %(1,~) is ext, (2,~) is frc

for i = 1:hei
    datcrp{1,i} = ext( segind(i):segind(i+1)-1 );
    datcrp{2,i} = frc( segind(i):segind(i+1)-1 );
end

%Zero somehow? std ok, or do linear first?
method = 1;
switch method
    case 1 %Subtract linear
        for i = 1:hei
            pf = polyfit(1:wid , datcrp{1,i},1);
            datcrp{1,i} = datcrp{1,i} - polyval(pf, 1:wid);
        end
        
    otherwise %0, do nothing
    
end

%Calculate pspec and mean(f)?
outx = cell(1,hei);
outy = nan(1,hei);
pspec = @(x) abs(fft(x)).^2 / Fs / (length(x)-1);
ff = (0:wid-1)/(wid-1)*Fs;
for i = 1:hei
    outx{i} = pspec ( datcrp{1,i} );
    outy(i) = mean( datcrp{2,i} );
end

%Bin forces. Use errbar. Group together
ybinsz = .01; %Just use tiny binsz for separate traces?
ybins = floor(min(outy)/ybinsz ): ceil(max(outy)/ybinsz);
ybins = ybins * ybinsz;
ii = discretize(outy,ybins);

xx = ybins(1:end-1)+ybinsz/2;
nbin = length(xx);
yy = cell(1,nbin);
% ee = nan(1,nbin);
nn = nan(1,nbin);
for i = 1:nbin
    tmp = outx(ii == i);
    nn(i) = length(tmp);
    
    if ~isempty(tmp)
        % For loglog, use geomean?
        yy{i} = geomean( reshape([tmp{:}], [], length(tmp)), 2);
%         ee(i) = std(tmp);
    end

end

figure, hold on
set(gca, 'XScale', 'log'), set(gca, 'YScale' , 'log')
cols = colorcircle(ceil((nbin+1)*1.1), 0.7);
% gfb = 1;
for i = 1:nbin
    if ~isempty(yy{i})
%         plot( geofilter( ff(2:floor(end/2)), gfb), geofilter(outx{i}(2:floor(end/2)), gfb), 'Color', cols{i} )
        plot( ( ff(2:floor(end/2))), (yy{i}(2:floor(end/2))), 'Color', cols{i} )
    end
end
cc = reshape([cols{1:nbin}], 3, [])';
colorbar
colormap(cc)
ax = gca;
ax.CLim = xx([1 end]); %Is the color in this order, or reverse?
axis tight

figure, plot(xx, nn)
% figure, errorbar(xx,yy,ee ./ sqrt(nn))
% xlabel('Force (pN)')
% ylabel('Noise (nm)')
% axis tight





