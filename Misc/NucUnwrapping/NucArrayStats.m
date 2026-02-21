function NucArrayStats(inst)

%Plot LF/HF histogram and scatter
hfbinsz = 2; %pN
hfxbinsz = 1; %nm
extnbin = 10; %N bins for LF/HF histograms

%Apply tfpbe
if isfield(inst, 'tfpbe1')
    inst = inst(logical([inst.tfpbe]));
end

xwlc = reshape([inst.xwlc], 5, [])';

lf = xwlc(:,4);
hf = xwlc(:,5)-xwlc(:,4);

figure('Name', 'LF Contour Histogram')
hist(lf, extnbin);
xlabel('Contour Length (nm)')
ylabel('Counts')

figure('Name', 'LF Force Histogram')
lff = [inst.lff];
hist(lff, extnbin);
xlabel('Force (pN)')
ylabel('Counts')


figure('Name', 'HF Histogram')
hist(hf, extnbin);
xlabel('Contour Length (nm)')
ylabel('Counts')

%Calculate HF Size
len = length(inst);
hfsz = cell(1,len);
for i = 1:len
    if isempty(inst(i).ext)
        continue
    end
    hfcon = [inst(i).hfx ./ XWLC( inst(i).hfs, inst(i).xwlc(1) ,inst(i).xwlc(2) ) inst(i).xwlc(3)+inst(i).xwlc(5)];
    hfcon = diff(hfcon);
    hfsz{i} = hfcon;
end



figure('Name', 'LF-HF Scatter')
scatter(lf,hf);
xlabel('Contour Length (nm)')
ylabel('Contour Length (nm)')

nhf = max( cellfun(@length, {inst.hfs}));
hfs = reshape([inst.hfs], nhf, [])';

fg = figure('Name', 'HF Force Plot');
edg =  (floor(min( hfs(:) ) / hfbinsz) : ceil(max( hfs(:) ) / hfbinsz)) * hfbinsz    ;

for i = 1:nhf
    ax = subplot2(fg, [1, nhf+1], i);
%     [yy, xx] = nhistc(hfs(:,i), hfbinsz);
    histogram(ax, hfs(:,i), edg, 'Normalization', 'prob', 'Orientation', 'horizontal');
    title(sprintf('HF %d', i))
    
    if i == 1
        ylabel('Force (pN)')
    end
end

ax=subplot2(fg, [1 nhf+1], nhf+1);
histogram(ax, hfs(:), edg, 'Normalization', 'prob', 'Orientation', 'horizontal');
title('All HFs')

axs = fg.Children;
linkaxes(axs, 'xy')


%Plot HF Size
fg = figure('Name', 'HF Size');
hfszs = reshape([hfsz{:}], nhf, [])';
edg =  (floor(min( hfszs(:) ) / hfxbinsz) : ceil(max( hfszs(:) ) / hfxbinsz)) * hfxbinsz    ;

for i = 1:nhf
    ax = subplot2(fg, [1, nhf+1], i);
%     [yy, xx] = nhistc(hfs(:,i), hfbinsz);
    histogram(ax, hfszs(:,i), edg, 'Normalization', 'prob', 'Orientation', 'horizontal');
    title(sprintf('HF %d', i))
    
    if i == 1
        ylabel('Force (pN)')
    end
end

ax=subplot2(fg, [1 nhf+1], nhf+1);
histogram(ax, hfszs(:), edg, 'Normalization', 'prob', 'Orientation', 'horizontal');
title('All HFs')

axs = fg.Children;
linkaxes(axs, 'xy')

