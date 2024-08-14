function out = avgPullsp2(inavg)
%Plots multiple outputs of avgPulls together
% Group together outputs in a cell array

toplot = 3; %Choose which plot to use, check code

yshift = 20; %Set 0 as fully wrapped

figure Name avgPullsP2
hold on
len = length(inavg);
errdat = cell(len, 3); %Errorbar data
cols = [223 31 38; 26 188 190]/225; %Set the first colors of the default colororder to Red/Cyan for Nuc/F
ax = gca;
ax.ColorOrder(1:2,:) = cols;

for i = 1:len
    %Get data. This is a matrix of row vectors of [trap sep, contour mean/sd/N, force mean/sd/N]
    tmp = inavg{i};
    
    
    %Pick force or contour data
    switch toplot
        case 1 %Tsep vs Force
            xx = tmp(1,:);
            dat = tmp(2:4,:);
            xlab = 'Trap Sep (nm)';
            ylab = 'Force (pN)';
        case 2 %Tsep vs Contour
            xx = tmp(1,:);
            dat = tmp(5:7,:);
            xlab = 'Trap Sep (nm)';
            ylab = 'Contour Length (nm)';
        case 3 %Force vs Contour
            xx = tmp(2,:);
            dat = tmp(5:7,:);
            xlab = 'Force (pN)';
            ylab = 'Contour Length (nm)';
%         case 4 %Force-Extension , oh ext isn't saved, use tsep for now
%             xx = tmp(2,:);
%             dat = tmp(5:7,:);
%             xlab = 'Force (pN)';
%             ylab = 'Contour Length (nm)';
    end
    
    %Extract values
    yy = dat(1,:) + yshift;
    
    %Calculate SEM
    ee = dat(2,:)./sqrt(dat(3,:));
    
    %And plot. Plot lines first so @legend 'works'
%     coi = get(gca, 'ColorOrderIndex');
    plot(xx, yy);
%     set(gca, 'ColorOrderIndex', coi)
    errdat{i,1} = xx;
    errdat{i,2} = yy;
    errdat{i,3} = ee;
%     errorbar2(xx, yy, ee)
    xlabel(xlab)
    ylabel(ylab)
end

set(gca, 'ColorOrderIndex', 1);
for i = 1:len
    errorbar2( errdat{i,:} );
end

for i = 1:len
    
end

%Calculate p value at every point with tt2sd
if len == 2
    hei = length(xx);
    pp = zeros(1,hei);
    switch toplot
        case 1
            row = 2;
        case 2
            row = 5;
        case 3
            row = 5;
    end
    for i = 1:hei
        pp(i) = tt2sd( inavg{1}(row, i), inavg{2}(row, i), ...
                       inavg{1}(row+1, i), inavg{2}(row+1, i), ...
                       inavg{1}(row+2, i), inavg{2}(row+2, i) );
    
    end
    out = pp;
    figure Name P-value
    plot(xx, pp);
    
end

