function ezDroAP_check(inst, xtra)
%Plots a diagnostic image, of APDV + region detection

if nargin < 2
    xtra = 0; %Plot extra stuff, see code
end

if length(inst) > 1
    arrayfun(@ezDroAP_check, inst);
    return
end

%Plot embimg

figure('Name', sprintf('ezDroAP_check: %s',inst.nam))

surface( zeros(size(inst.embimg)), imgaussfilt(inst.embimg,1) , 'EdgeColor', 'none')
hold on
colormap jet
axis tight

% %Get img and scale to same brightness? Maybe not necessary?
% movimg = inst.dat(end).imgraw;
% % movimg = movimg * (1 / max( movimg(:) ) * max( inst.embimg(:) ) );
% surface( zeros(size(movimg)), imgaussfilt(movimg,1), 'EdgeColor', 'none' )

%Draw APDV, code from ezDroAP
apdv = inst.apdv;
txt = 'APDV';
txts = cell(1,4);
for i = 1:4
    plot(apdv{i}(1), apdv{i}(2),'o', 'LineWidth',2,'MarkerSize', 5)
    txts{i} = text(apdv{i}(1), apdv{i}(2), txt(i), 'Color', [1 1 1], 'FontSize', 14, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
end

%xtra >= 1: Plot A/P axis and midpoint
if xtra >= 1
    %Draw AP line and pos/neg
    mp = (apdv{1} + apdv{2} )/2;
    seg1 = [apdv{1}; mp];
    seg2 = [apdv{2}; mp];
    
    plot(seg1(:,1), seg1(:,2), 'b')
    plot(seg2(:,1), seg2(:,2), 'r')
    scatter(mp(1),mp(2),'k')
end

%xtra >= 2: Plot points from fitRise and their AP coords
if xtra >= 2
    %Check for fitRise field
    if isfield(inst, 'fitRise')
        fr = inst.fitRise;
        for i = 1:length(fr)
            %Plot x,y. Convert to new space
            
            %plot CenAPDV, offset? single color? what to do...
            
        end
    end
end



%Draw box, from ezDroMoviePos
rectangle('Position', [ inst.movpos(1:2), fliplr(size(inst.dat(1).img)) * inst.movpos(3)], 'EdgeColor', [1 1 1], 'LineWidth', 1 )