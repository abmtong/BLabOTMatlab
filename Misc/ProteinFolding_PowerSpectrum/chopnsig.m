function out = chopnsig(ext, frc, wid)
%

if nargin < 3
    wid = 1e5; %pts
end

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


%Calculate std(x) and mean(f)?
out = nan(2,hei);
for i = 1:hei
    out(1,i) = std ( datcrp{1,i} );
    out(2,i) = mean( datcrp{2,i} );
end

% figure, plot(out(2,:), out(1,:))
% xlabel('Force (pN)')
% ylabel('Noise (nm)')
% axis tight
% %Remove high Y outliers
% ymx = prctile(out(1,:),95);
% ylim([-inf ymx])

%Bin forces. Use errbar
ybinsz = .1;
ybins = floor(min(out(2,:))/ybinsz ): ceil(max(out(2,:))/ybinsz);
ybins = ybins * ybinsz;
ii = discretize(out(2,:),ybins);

xx = ybins(1:end-1)+ybinsz/2;
nbin = length(xx);
yy = nan(1,nbin);
ee = nan(1,nbin);
nn = nan(1,nbin);
for i = 1:nbin
    tmp = out(1, ii == i);
    if ~isempty(tmp)
        yy(i) = mean(tmp);
        ee(i) = std(tmp);
        nn(i) = length(tmp);
    end
end
figure, errorbar(xx,yy,ee ./ sqrt(nn))
xlabel('Force (pN)')
ylabel('Noise (nm)')
axis tight





