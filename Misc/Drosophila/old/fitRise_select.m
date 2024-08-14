function [outki, outraw] = fitRise_select(instc)
%input: output of fitRise, can take cell of multiple outputs and plots separately

%For now lets plot the (const, slope) distribution of r + g

%Let's select some slice of the slope/intercept space? Top 50%? 
opts.selectmeth = 1; %Select method

%Method 1: Range of percentiles
opts.m1.prcco = [25 75]; %Take center 50% in each dimension


if ~iscell(instc)
    instc = {instc};
end

hei = length(instc);
outraw = cell(1,hei);
outki = cell(1,hei);

for j = 1:hei
    inst = instc{j};
    
    len = length(inst);
    bmbm = nan(len,5); %Const, slope, const, slope for ch1, ch2 , then frame delay
    
    
    for i = 1:len
        tmp = inst(i);
        %Only take data that exists
        if ~isempty(tmp.frraw{1}) && ~isempty(tmp.frraw{2})
            bmbm(i,:) = [tmp.frraw{1}{1}{2} tmp.frraw{1}{1}{3} tmp.frraw{2}{1}{2} tmp.frraw{2}{1}{3} tmp.fr(1)-tmp.fr(2)]; %Cancerous, but eh
        end
        
    end
    
    %Make plot figure
    if j == 1
        figure
        ax1 = subplot(2,1,1);
        ax2 = subplot(2,1,2);
        hold(ax1, 'on');
        hold(ax2, 'on');
        xlabel(ax1, 'Intercept')
        xlabel(ax2, 'Intercept')
        ylabel(ax1, 'Slope')
        ylabel(ax2, 'Slope')
        zlabel(ax1, 'Delay')
        zlabel(ax2, 'Delay')
    end
    
    %Plot scatter
    scatter3(ax1,  bmbm(:,1), bmbm(:,2), bmbm(:,5) )
    scatter3(ax2, bmbm(:,3), bmbm(:,4), bmbm(:,5) )
    
    
    outraw{i} = bmbm;
    
    %Apply filtering to get ki
    for i = 1:4
        
        
    end
    
end



%Un-cell if only one input
if hei == 1
    outki = outki{1};
    outraw = outraw{1};
end

