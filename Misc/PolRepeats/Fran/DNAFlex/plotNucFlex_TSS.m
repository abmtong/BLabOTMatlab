function out = plotNucFlex_TSS(inst, bins)
%Plots cyc vs Nuc number

if nargin < 2
    %Define bins
    % bins = [1:10 20:10:100 200:100:1e3]; %Nuc relative to TSS bins. Or do it in sequence space?
    % bins = 1:1e3;
    % bins = 0:10:1e3;
    % bins = [1:10 20:10:150];
    
    %Probably use these two:
    % 10 binsize for larger scale
    bins = 1:5:151;
    % 1 binsize for smaller scale
    % bins = 1:20;
end

%Hmm data at pos 25 is from nt 1-50, so from -24 to +25. So maybe we need to average to get the true center
% So from -24 to +25 and -25 to +24 averaged (i.e., pos i is actually the average of i and i-1


cols = [0 1 0; 0 0 0; 1 0 0]; %Colors, used to set the main axis color order
% Default Proximal = Green, Dyad = Black, Distal = Red

nbin = length(bins)-1;
% bins = [bins inf];

%Classify each by the gene type
genid = zeros(1, length(inst));
nnos = nan(1, length(inst));
for i = 1:length(inst)
    gen = inst(i).gen;
    %No gene:
    if isempty( gen )
        genid(i) = 0; %No gene
    else
        %Get the strands that these genes appear on
        str = [gen.strand];
        
        if length(str) > 1
            genid(i) = 2; %HERE classify 'both' as 'in multiple genes', even if the same dir
        end
        
        %Save Nuc Number
        nnos(i) = gen.nucnum ;
        
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

nbp = length(inst(1).cyc);

dy = (nbp-1)/2+1; %151

pos = [-48 0 47]; %Positions to take relative to dyad
 % Since its 50bp windows, we need to take -48 and +47 because we're rotating around a single value

nam = {'Proximal Arm' 'Dyad' 'Distal Arm'};

figure( 'Name' ,'plotDcP_TSS', 'Color', [1 1 1] )
ax = gca;
ax.ColorOrder = cols;
hold on
plottyp = {'-o' '' '--x'}; %Line type, to differentiate m/p
sgn = '-0+b';
gnum = [-1 0 1 2];
lgn = cell(1, length(pos));

%Get + strand data
ki = find(genid == 1);
hei = length(ki);
dp = zeros(3, hei);
for j = 1:hei
    dp(:, j) = inst( ki(j) ).cyc( pos+dy );
end
% dp = reshape( [inst(genid == 1).cyc], nbp, [] );

tp = nnos(genid == 1);

%Get - strand data
ki = find(genid == -1);
hei = length(ki);
dm = zeros(3, hei);
for j = 1:hei
    dm(:, j) = inst( ki(j) ).cyc( pos+dy );
end
% %Since cyc is for 50bp windows, let's make it an odd-numbered window by averaging two adjacent points together
% dm = (dm(2:end-1, :) + dm(1:end-2, :) ) /2;
tm = nnos(genid == -1);
% And flip the arms of this one
dm = flipud(dm);

%Concatenate
dall = [dp dm];
tall = [tp tm];

out = cell(1, length(pos));
%For left arm, dyad, right arm...
for j = 1:length(pos)
    
    %Get just this arm's flexibility
%     d = dall( dy + pos(j), :);
    d = dall(j,:);
    %Remove NaNs
    ki = ~isnan(tall);
    d = d(ki);
    t = tall(ki);
    
    
    %Bin
    %         bined = [1 zeros(1,nbin)];
    by = zeros(1,nbin);
    bx = zeros(1,nbin);
    bn = zeros(1,nbin);
    bsd = zeros(1,nbin);
    for k = 1:nbin
        
        ki = t >= bins(k) & t < bins(k+1);
        
        tmp = d(ki);
        
        %Scale
        tmp = scaleCyc(tmp);
        
        %And bin. Weight by N
        bx(k) = mean(t(ki));
        by(k) = mean(tmp);
        bn(k) = length(tmp);
        bsd(k)= std(tmp);
    end
    
    %And plot
    %         plot(bx, by, plottyp{1})
    errorbar(bx, by, bsd ./ sqrt(bn), plottyp{1})
    
    lgn{1,j} = sprintf('%s', nam{j});
    
    out{i} = [bx(:) by(:) bsd(:) bn(:)];
end
% end
%
% %Ugh, lgn is actually size 3xn
% %Remove middle col
% lgn = lgn([1 3], :);

%Apply legend
lgn = lgn';

legend(lgn(:));
axis tight
ylabel('Predicted Flexibility (DNAcycP, normalized)')
xlabel('Nucleosome Number relative to Transcription Start Site')

out = {bx by bn bsd};
