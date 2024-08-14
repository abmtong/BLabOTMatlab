function out = plotTraces_TxPullp2(inst)
%Input: output of plotTraces_TxPull

%Plot to ascertain Nuc state

fil = 100;
% xwlcg = [50 1300]; %OK for HiRes 4kb
xwlcg = [55 397]; %For HiRes 2kb

% dx = 30;
dx = 0; %5kb Nucs

% fcr = 13; %13 for ext ~ con
fcr = 7; %Choice for a point past LF but before +F HF

figure Name plotExt
hold on
ax1 = gca;
xlabel( 'Extension (nm, rel)')
ylabel( 'Force (pN)')

figure name plotCon
hold on
ax2 = gca;
xlabel( 'Force (pN)')
ylabel( 'Contour (bp, rel)')
len=length(inst);
xwlcs = cell(1,len);
for i = 1:len
    xx = inst(i).ext;
    yy = inst(i).frc;
    
%     
    xx = windowFilter(@mean, xx, [], fil);
    yy = windowFilter(@mean, yy, [], fil);
    
    indend = find( yy > 3, 1, 'last');
    
    %Try to pad a bit
    indend = min(indend + 1 , length(xx) );
    
    xx = xx(1:indend);
    yy = yy(1:indend);
    
%     xx = xx(1:indend);
%     yy = yy(1:indend);
    
    cc = xx ./ XWLC(yy, xwlcg(1), xwlcg(2));
    
    %Zero... somehow
    ind = find(yy > fcr, 1, 'first');
    if isempty(ind)
        continue
    end
    x0 = xx(ind);
    c0 = cc(ind);
    
    
    plot(ax1, xx - x0 + dx*i,yy)
    plot(ax2, yy, cc - c0 + dx*i)
    try
        xwlcs{i} = fitForceExt(xx(1:end-3), yy(1:end-3)); %Trim some edge stuff
    catch
        xwlcs{i} = nan(1,5);
    end
end

% out = reshape([xwlcs{:}], [], length(xwlcs))';