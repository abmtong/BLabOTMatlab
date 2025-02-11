function out = avgCdd(inst)

%Averages CDD bits among secondary structures

npt = 1e3;
len = length(inst);
smoothalpha = 1;

%Convert bit index to 1D index
bits = cell(1,len);
for i = 1:len
    
    tmp = nan(1, max( max( [inst(i).ssez{:}] ) ) );
    tmp(inst(i).bits(:,1)) = inst(i).bits(:,2);
    bits{i} = tmp;
end

nss = max( arrayfun(@(x)length(x.ssez), inst) );
outraw = cell(nss,len);
for i = 1:nss
    %Grab this ss
    for j = 1:len
        %Make sure this ss is here
        if length(inst(j).ssez)>=j
            rng = inst(j).ssez{i};
            tmp = bits{j}(rng(1):rng(2));
            
            %Maybe filter alphas so it's 'highest per turn' ?
            if smoothalpha && mod(i, 2) == 0
                %Filter with width 3 (since helical turn is 3.6aa)
                tmp = windowFilter(@max, tmp, 1, 1);
            end
            
            outraw{i,j} = bitresample( tmp, npt );
            
%             st = find(inst(j).bits(:,1) >= rng(1), 1, 'first');
%             en = find(inst(j).bits(:,1) <= rng(2), 1, 'last');
%             
%             outraw{i,j} = bitresample( inst(j).bits(st:en,2) , npt);
        else
            outraw{i,j} = nan(1, npt);
        end
    end
    
    
end

%Permute SSEs
% kimix = 1:9; %1-9
% kimix = [1 3 5 7 9 2 4 6 8]; %b first, then a
kimix = [9 7 1 3 5 2 4 6 8]; %b first, sheet order

%Combine
outraw = outraw';
outraw = outraw(:, kimix);
outraw = cell2mat(outraw);
out = mean(outraw, 1, 'omitnan');
xx = (1:length(out))/npt;

%Plot
figure, hold on
for i = 1:len
    plot(xx, outraw(i,:))
end
plot(xx, out, 'k', 'LineWidth', 2)

%Add divider lines
yl= ylim;
for i = 0:nss
    line( [i i], [0 yl(2)], 'Color', 'k' )
end

%Label
labs = {'\beta1' '\alpha2' '\beta3' '\alpha4' '\beta5' '\alpha6' '\beta7' '\alpha8' '\beta9'};
labs = labs(kimix);
for i = 1:length(labs)
    text(i - 0.5, 0.5, labs{i}, 'FontSize', 16, 'HorizontalAlignment', 'center')
end
xlim([0 nss])

ylabel('Sequence Conservation (bits)')
xlabel('Secondary Structure Element (N>C, scaled)')

%Remove the tick labels since we've covered it with text
set(gca, 'XTickLabel', [])

%Plot 2: Bs and As, same graph



