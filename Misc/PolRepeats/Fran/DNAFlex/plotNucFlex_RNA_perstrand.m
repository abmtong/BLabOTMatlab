function plotNucFlex_RNA_perstrand(inst)
%Plots cyc vs TPM

%Same as plodDcP_RNAseq in V1. Works!

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

nbin = 10; %Divide into 10 pts

nbp = length(inst(1).cyc);

dy = (nbp-1)/2+1; %151

pos = [-48 0 48]; %Positions to take relative to dyad
nam = {'Prox Arm' 'Dyad' 'Distal Arm'};

figure Name plotDcP_RNAseq2
ax = gca;
hold on
plottyp = {'-o' '' '--x'}; %Line type, to differentiate m/p
sgn = '-0+b';
gnum = [-1 0 1 2];
lgn = cell(2, length(pos));
for i = [1 3] %m p
    %Get data, reshape
    dall = reshape( [inst(genid == gnum(i)).cyc], nbp, [] );
    tall = tpms(genid == gnum(i));
    
    %Crop to length d
%     tall = tall(1: size(dall, 2) );
    
    %Reset plot color order
    set(ax, 'ColorOrderIndex', 1);
    
    for j = 1:length(pos)
        
        %Get just this pos. Align to RNAP, so swap (-) strand
        if i == 1
            d = dall( dy - pos(j), :);
%             t = tall( dy - pos(j), :);
        else
            d = dall( dy + pos(j), :);
%             t = tall( dy + pos(j), :);
        end
        %Remove NaNs
        ki = ~isnan(tall);
        d = d(ki);
        t = tall(ki);
        
        %Bin by unique
        [uy, ux, un, usd] = uniquebin(t, d);
        
        %Split into bins by nbin
        uncs = cumsum(un(2:end));
        
        bined = [1 zeros(1,nbin)];
        by = zeros(1,nbin);
        bx = zeros(1,nbin);
        bn = zeros(1,nbin);
        bsd = zeros(1,nbin);
        for k = 1:nbin
            %Find first bin > N/nbin
            bined(k+1) = find( uncs >= k / nbin * uncs(end), 1, 'first' );
            
            %And bin. Weight by N
            bx(k) = sum(ux( bined(k):bined(k+1)-1 ) .* un( bined(k):bined(k+1)-1 )) / sum( un( bined(k):bined(k+1)-1 ) );
            by(k) = sum(uy( bined(k):bined(k+1)-1 ) .* un( bined(k):bined(k+1)-1 )) / sum( un( bined(k):bined(k+1)-1 ) );
            bn(k) = sum( un( bined(k):bined(k+1)-1 ) );
            bsd(k)= sum(usd( bined(k):bined(k+1)-1 ) .* un( bined(k):bined(k+1)-1 )) / sum( un( bined(k):bined(k+1)-1 ) ); 
            % SD weighting like this is not accurate, but close enough?
        end
        
        %Scale
        by = scaleCyc(by);
        bsd = scaleCyc(bsd, 2);
        
        %And plot
%         plot(bx, by, plottyp{i})
        errorbar(bx, by, bsd ./ sqrt(bn), plottyp{i})
        
        lgn{i,j} = sprintf('%s Gene, %s', sgn(i), nam{j});
        
        
    end
end

%Ugh, lgn is actually size 3xn
%Remove middle col
lgn = lgn([1 3], :);

%Apply legend
lgn = lgn';

legend(lgn(:));
axis tight
ylabel('DNAcycP Predicted Cyclyzability')
xlabel('TPM score')

