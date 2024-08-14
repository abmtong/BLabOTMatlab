function plotIF(inst, tgt)

%Plots G/R ratio (or whatever else) from an input struct
%Struct has fields name and dat

if nargin < 2
    tgt=1;  %Target, see code. i.e., 'what to plot'
end


figure('Color', [1 1 1]);
hold on

for i = 1:length(inst)
    
    switch tgt
        case 1 %G/R, peak 1
            yy = inst(i).dat(:,26);
            ee = inst(i).dat(:,26+1);
            sz = 36; %Basic scatter size
            ylbl = 'GFP/mCh ratio';
            tit = 'GFP/mCh ratio of Peak 1';
        case 2 %G/R, peak 2
            yy = inst(i).dat(:,26+6);
            ee = inst(i).dat(:,26+7);
            sz = 36; %Basic scatter size
            ylbl = 'GFP/mCh ratio';
            tit = 'GFP/mCh ratio of Peak 2';
            % Probably bad, too few in peak 2
        case 3 % PctG/ PctR, peak 1
            yy = inst(i).dat(:,26+2);
            ee = inst(i).dat(:,26+3);
            sz = 36; %Basic scatter size
            ylbl = 'GFP/mCh ratio';
            tit = 'GFP/mCh ratio of Peak 1';
            % Probably bad
        case 4 %G, peak 1
            yy = inst(i).dat(:,2);
            ee = inst(i).dat(:,2+1);
            sz = 36; % inst(i).dat(:,3); %Basic scatter size
            ylbl = 'GFP value';
            tit = 'GFP intensity of Peak 1';
        case 5 %R, peak 1
            yy = inst(i).dat(:,2+6);
            ee = inst(i).dat(:,2+7);
            sz = 36; %Basic scatter size
            ylbl = 'mCherry value';
            tit = 'mCh intensity of Peak 1';
    end
    coi = get(gca, 'ColorOrderIndex');
    errorbar(inst(i).dat(:,1), yy, ee, 'LineStyle', 'none');
    set(gca, 'ColorOrderIndex', coi);
    scatter(inst(i).dat(:,1), yy, sz, 'o', 'MarkerFaceColor', 'flat')
    
    
end

%Reorder plots so legend works
ch = get(gca, 'Children');
ch = ch([2:2:end 1:2:end]);
set(gca, 'Children', ch);
lgn = {inst.name};
lgn = cellfun(@(x) strrep(x, '_', '-'), lgn, 'Un', 0);
legend(lgn);
xlabel('Induction Time (min)')
ylabel(ylbl)
title(tit)