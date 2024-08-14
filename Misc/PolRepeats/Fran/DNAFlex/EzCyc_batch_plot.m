function [ out outp ] = EzCyc_batch_plot(datall)
%Plot output of EzCyc_Batch_plot

%Basically, ... we want to do the Entry-Exit-Dyad for all genes?

pos = [-48 0 47];

len = length(datall);
out = cell(1,len);
outp = cell(1,len);
for i = 1:len
    %Get data. This is nbp x 4, of [x mean sd N]
    armm = datall(i).flex{1};
    armp = datall(i).flex{3};
    
    %Find midpoint = dyad
    nbp = size(armm, 1);
    dy = round(nbp+1)/2;
    
    %Get l/d/r
    mm = armm(dy + pos, :);
    pp = armp(dy + pos, :);
    
    %And organize this as Entry- Entry+ Dy- Dy+ Exit- Exit+ Zeroes
    out{i} = [ mm(3,:); pp(1,:); mm(2,:); pp(2,:); mm(1,:); pp(3,:); mm(1,:)*0 ];
    
    %And heck take p-values, between Entrys, Exits, -, +
    pr = [1 2; 5 6; 1 5; 2 6];
    pp = zeros(1,4);
    for j = 1:4
        pp(j) = tt2sd(out{i}( pr(j,1),2), out{i}(pr(j,2),2), out{i}(pr(j,1),3), out{i}(pr(j,2),3),out{i}(pr(j,1),4), out{i}(pr(j,2),4) );
    end
    outp{i} = pp;
end

%Concatenate
dat = cell2mat(out(:));

%Strip final row = last zeroes column
dat = dat(1:end-1,:);

%Plot bar and error
xx = 1:length(dat);
yy = dat(:,2);
ee = dat(:,3)./sqrt(dat(:,4));


figure('Name', 'EzCycBatchPlot', 'Color', [1 1 1])
hold on
% bar(xx, yy)
% errorbar(xx, yy, ee, 'LineStyle', 'none')

%Plot proximal as green, dyad as black, distal as red
cols = 'gkr';
for i = 1:3
    i0 = (i-1)*2;
    plot(xx(i0+1:7:end), yy(i0+1:7:end), 'LineStyle', 'none', 'Marker', 'x', 'Color', cols(i))
    plot(xx(i0+2:7:end), yy(i0+2:7:end), 'LineStyle', 'none', 'Marker', 'o', 'Color', cols(i))
end
%Plot lines and errorbar2 separately to preserve legend order
for i = 1:3
    i0 = (i-1)*2;
    errorbar2(xx(i0+1:7:end), yy(i0+1:7:end), ee(i0+1:7:end), 1, 'Color', cols(i))
    errorbar2(xx(i0+2:7:end), yy(i0+2:7:end), ee(i0+2:7:end), 1, 'Color', cols(i))
end


%Add black bars between data
yl = ylim;
for i = 1:len-1
    line(i*7 * [1 1], yl, 'Color', 'k')
end

%Add some signifier for significance
al = 1e-2; %Significance level
yl = ylim; 

ystarpos = yl(1) + (yl(2)-yl(1))/20; %Position to plot stars at

for i = 1:len
    %Check: ... If outp(3, 4) are small ?
    str = [];
    
    pp = outp{i}(3:4);
    if pp(1) < al ; %Minus strand
        str = [str '-*'];
    end
    if any(pp < al)
        str = [str '+*'];
    end
    if ~isempty(str)
        text(3.5  + (i-1)*7 , ystarpos, str, 'HorizontalAlignment', 'center')
    end
end


legend({'Entry arm, - Strand' 'Entry arm, + Strand' 'Dyad, - Strand' 'Dyad, + Strand' 'Exit arm, - Strand' 'Exit arm, + Strand'})

%Manipulate axes
axis tight
ax = gca;
ax.XTick = -3.5 + (1:len)*7;
ax.XTickLabelRotation = 90;
ax.XTickLabel = arrayfun(@(x) sprintf('%d', x), 1:len, 'Un', 0);
xlim([0 len*7]);

ax.TickDir = 'out';
ylabel('Flexibility (DNAcycP, arbitrary)')



