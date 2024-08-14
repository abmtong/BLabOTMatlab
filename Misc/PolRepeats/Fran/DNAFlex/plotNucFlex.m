function out = plotNucFlex(inst)
%Plot by gene direction. Same as plotDcP of V1

% Recreates the same pattern as V1 for hg17, so good!


%Classify each by the gene type
genid = zeros(1, length(inst));
for i = 1:length(inst)
    gen = inst(i).gen;
    %No gene: 
    if isempty( gen )
        genid(i) = 0; %No gene
    else
        %Get the strands that these genes appear on
        str = [gen.strand];
        
        %And classify
        if all(str == 1)
            genid(i) = 1; %Plus strand
        elseif all(str == 0)
            genid(i) = -1; %Minus strand
        else
            genid(i) = 2; %Both
        end
    end
end


figure('Name', sprintf('PlotNucFlex by gene direction: %s',inputname(1)), 'Color', [1 1 1])
hold on
nn = zeros(1,4);
nbp = length(inst(1).cyc);
ids = [-1 0 1 2];

out = cell(1, 4);
for i = 1:4
%     %Concatenate and reshape
%     tmp = reshape([inst( ids(i) == genid  ).cyc], nbp , []);
%     %Scale to human genome values
%     tmp = scaleCyc(tmp);
%     nn(i) = size(tmp, 2);
%     xx = (1:size(tmp,1)) - round(size(tmp, 1)/2) + 0.5;
%     yy = mean(tmp, 2, 'omitnan')';
%     y2 = median(tmp, 2, 'omitnan')';
%     ee = std(tmp, [], 2, 'omitnan')' / sqrt( size(tmp, 2) );

    %ACTUALLY replace with a low-memory compatible version, since some of these are BIG
    
    ki = find(ids(i) == genid);
    hei = length(ki);
    %Calculate mean
    tmpn = 0;
    tmpm = zeros(1, nbp);
    for j = 1:hei
%         %Handle NaN. Do we need to? Just skip NaNs for 'speed'
        tmp = inst( ki(j) ).cyc;
        if any(isnan(tmp))
            continue
        end
        tmpn = tmpn + 1;
        tmpm = tmpm + tmp;
    end
    yy = tmpm ./ tmpn;
    
    %Calculate SD
    tmpn = 0;
    tmpm = zeros(1, nbp);
    for j = 1:hei
        %Handle NaN. Do we need to?
        tmp = inst( ki(j) ).cyc;
        if any(isnan(tmp))
            continue
        end
        
        tmpn = tmpn + 1;
        tmpm = tmpm + (tmp - yy).^2;
    end
    sd = sqrt( tmpm ./ (tmpn-1) );
    
    %Scale Cyc
    yy = scaleCyc(yy);
    sd = scaleCyc(sd, 2);
    ee = sd ./ sqrt(tmpn);
    nn(i) = max(tmpn);
    xx = (1:nbp)  - round(nbp/2) + 0.5;

    %CHECKED that it's the same for Hg17. Very similar runtime.

%     %Since cyc is for 50bp windows, let's make it an odd-numbered window by averaging two adjacent points together
%     %ACTUALLY lets just make the x-values as +0.5 for this one

    
    
    %Flip the genes on the (-) strand
    if i == 1 %Hard-coded order of -, 0, +, both
        %For - strand genes, plot regular and flipped
        plot(xx,yy)
        xx = fliplr(xx);
    end
    ob = plot(xx,yy); %Plot mean
%     plot(xx,y2); %Plot median
%     errorbar(xx,yy,ee); %Plot mean +- SEM, @errorbar isn't a great way to do this
    %Plot mean +- SEM as data band
    surfx = [xx fliplr(xx)];
    surfy = [yy + ee fliplr(yy-ee)];
%     surfz = zeros(size(surfx));
    curcol = ob.Color;
    %Plot data band, lighter color + transparent
    patch(surfx, surfy, mean( [curcol; 1 1 1], 1), 'FaceAlpha', 0.5, 'EdgeColor', 'none') 
%     surface([surfx;surfx], [surfy;surfy], [surfz;surfz], 'EdgeColor', 'none', 'FaceColor', mean( [curcol; 1 1 1], 1) )

    %Save the raw plot data for convenience
    out{i} = [xx(:) yy(:) sd(:) nn(i) * ones( length(xx), 1 )];
end

% %Plot 601 as a reference line
% % Load from file
% cycref = load('cyc601.mat', 'cyc601');
% cycref = cycref.cyc601;
% %Center
% cycxx = (1:length(cycref)) - round(length(cycref)/2);
% %Scale to the same range as the current graph
% yl = ylim;
% wid = 0.05; %Pad on both sides by this amount of ylim
% cycyy = (cycref - min(cycref)) / range(cycref) * range(yl) *(1-wid*2) + yl(1) + range(yl)*wid;
% plot(cycxx, cycyy, 'k')

%Legend and N
nam0 = {'Gene <- (flipped)' 'Non-gene' 'Gene ->' 'Gene both'};
nams = cellfun(@(x,y) sprintf('%s, N=%d', x, y), nam0, num2cell(nn), 'Un', 0);
%If we also plotted patches, add 'Mean +- SEM'
nams = [nams; repmat({'Mean±SEM'},1,4)];
nams = [{'Gene <-'} nams(:)'];
% nams = [{'Gene <-'} nams(:)' {sprintf('601 (scaled, normal range %0.2f-%0.2f)', min(cycref), max(cycref))}];
legend(nams)
% legend({'Gene <- (flipped)' 'Non-gene' 'Gene ->' 'Gene both'})
% legend({'Gene <- (flipped)' '' 'Non-gene' '' 'Gene ->' '' 'Gene both' ''})

%Axis labels
ylabel('Predicted Cyclyzability (DNAcycP, normalized))')
xlabel('Position from Dyad (bp)')

%Add guidelines for entry/dyad/exit
axis tight
yl = ylim;
arrayfun(@(x) line(147/2 * [1 1] * x, yl), -1:1)

%Shade 25bp off each edge, since this data is 'meaningless'
xl = xlim;
rectangle('Position', [xl(1) yl(1) 25 diff(yl)], 'EdgeColor', 'none', 'FaceColor', [0 0 0 0.25])
rectangle('Position', [xl(2)-25 yl(1) 25 diff(yl)], 'EdgeColor', 'none', 'FaceColor', [0 0 0 0.25])




