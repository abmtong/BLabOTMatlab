function sgolaytester(inTrace, indeg, inwid, realsignal)

yl = [min(inTrace) max(inTrace)];
xl = [1 length(inTrace)];
%widths must be odd, at least 3
inwid(mod(inwid,2) == 0) = [];
inwid(inwid < 3) = [];

len = length(indeg);
hei = length(inwid);

figure('Name', sprintf('sgolaytester [%s] x [%s]', sprintf('%d,', indeg), sprintf('%d,', inwid)));

for i = 1:len
    for j = 1:hei
        %degree must be smaller than width -1
        if ~ ( indeg(i) < inwid(j) -1 )
            continue
        end
        axes('Units', 'Normalized', 'Position', [(i-1)/len (j-1)/hei 1/len 1/hei])
        plot(inTrace, 'Color', [.7 .7 .7])
        hold on
        plot(sgolayfilt(inTrace, indeg(i), inwid(j)))
        if nargin > 3
            hold on
            plot(realsignal)
        end
        text(mean(xl), mean(yl), sprintf('[%d, %d]', indeg(i), inwid(j)))
        xlim(xl);
        ylim(yl);
    end
end