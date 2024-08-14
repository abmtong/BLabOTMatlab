function out = plotNucFlex_RNA(inst, bins)
%Plots cyc vs TPM


if nargin < 2
    %TPM is vaguely log-distributed...
    bins = [0 1e-2 1e-1 1 1e1 1e2 inf];
    
    bins = [0 logspace(-2, 2, 10) inf];
    
end
nbin = length(bins)-1;

cols = [0 1 0; 0 0 0; 1 0 0]; %Colors, used to set the main axis color order
                            % Default Proximal = Green, Dyad = Black, Distal = Red


%Classify each by the gene type
genid = zeros(1, length(inst));
tpms = nan(1, length(inst));
for i = 1:length(inst)
    gen = inst(i).gen;
    %No gene:
    if isempty( gen )
        genid(i) = 0; %No gene
    else
        %Get the strands that these genes appear on
        str = [gen.strand];
        
        %Save TPM
        tpms(i) = max( [gen.tpm] );
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

% nbin = 10; %Divide into 10 pts

nbp = length(inst(1).cyc);

dy = (nbp-1)/2+1; %151

pos = [-48 0 47]; %Positions to take relative to dyad
 % Since its 50bp windows, we need to take -48 and +47 because we're rotating around a single value
 % i.e., so [-48, 0, 47] + 0.5 = [-47.5, 0.5, 47.5] ; dyad is off a bit but EH
nam = {'Proximal Arm' 'Dyad' 'Distal Arm'};

figure( 'Name', 'plotDcP_RNAseq' , 'Color', [1 1 1] )
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

tp = tpms(genid == 1);

%Get - strand data
ki = find(genid == -1);
hei = length(ki);
dm = zeros(3, hei);
for j = 1:hei
    dm(:, j) = inst( ki(j) ).cyc( pos+dy );
end

% dm = reshape( [inst(genid == -1).cyc], nbp, [] );
% %Since cyc is for 50bp windows, let's make it an odd-numbered window by averaging two adjacent points together
% dm = (dm(2:end-1, :) + dm(1:end-2, :) ) /2;
tm = tpms(genid == -1);
% And flip this one to match
dm = flipud(dm);

%Concatenate
dall = [dp dm];
tall = [tp tm];

out = cell(1, length(pos));
for i = 1:length(pos)
    
    %Get this arm
%     d = dall( dy + pos(i), :);
    d = dall(i,:);
    
    %Remove NaNs
    ki = ~isnan(tall);
    d = d(ki);
    t = tall(ki);
    
    %And bin
    by = zeros(1,nbin);
    bx = zeros(1,nbin);
    bn = zeros(1,nbin);
    bsd = zeros(1,nbin);
    for k = 1:nbin
        ki = t >= bins(k) & t < bins(k+1);
        tmp = d(ki);
        
        %Scale
        tmp = scaleCyc(tmp);
        
        %And bin
        bx(k) = mean( t(ki) );
        by(k) = mean( tmp );
        bn(k) = length(tmp);
        bsd(k)= std( tmp );
    end
    
    %And plot
    %         plot(bx, by, plottyp{1})
    
%     warning('Hack: Adding 1e-3 to first x-position')
    errorbar( max(bx, 1e-3), by, bsd ./ sqrt(bn), plottyp{1})
    
    %         errorbar(bx, by, bsd ./ sqrt(bn), plottyp{1})
    
    %Append legend
    lgn{i} = sprintf('%s', nam{i});
    
    %Save plot data
    out{i} = [bx(:) by(:) bsd(:) bn(:)];
    
end

%Apply legend
lgn = lgn';

legend(lgn(:));
axis tight
ylabel('Predicted Cyclyzability (DNAcycP, normalized)')
xlabel('RNA-seq score (Transcripts per million transcripts)')
ax.XScale = 'log';

