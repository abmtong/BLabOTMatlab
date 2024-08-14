function ezPlotOmarBar(inst, cropstr, style)

if nargin < 3
    style = 2;
end

source = 1; %1: MLE vs 2: Curve fit. Curve fit might have too small MLEs

if nargin < 2
    cropstr = 'expcrop';
end

%Get data (exp fits)
len = length(inst);
for i = length(inst):-1:1
    switch source
        case 1
            rawdat{i} = inst(i).(cropstr);
        case 2
            [~, ikeep] = min( inst(i).([cropstr 'raw']).aics );
            rawdat{i} = [inst(i).([cropstr 'raw']).cfits{ikeep} ; inst(i).([cropstr 'raw']).cfcis{ikeep}];
    end
end


%Create matrix of a's, ks, and CIs
maxi = max( cellfun (@(x) size(x,2) /2, rawdat) );
a = zeros(maxi, len);
k = zeros(maxi, len);
ae = zeros(maxi, len);
ke = zeros(maxi, len);
for i = 1:len
    raw = rawdat{i};
    n = size(raw,2)/2;
    
    tmp = raw(1, 1:2:end);
    a( 1:n, i) = tmp;
    
    tmp = raw(1, 2:2:end);
    k( 1:n, i) = tmp;
    
    tmp = raw(2, 1:2:end);
    ae( 1:n, i) = tmp;
    
    tmp = raw(2, 2:2:end);
    ke( 1:n, i) = tmp;
end

%And plot, based on style

switch style
    case {1 2} %As together, Ks together, grouped by condition
        figure('Name', 'PlotOmarBar a/k', 'Color', ones(1,3))
        
%         ax = subplot2([2 maxi], 1);
%         hold(ax, 'on')
        
        %Transpose if style == 2
        if style == 2
            a = a';
            ae = ae';
            k = k';
            ke = ke';
        end
        
%         %Reshape bars to be grouped with spaces
%         a(end+1,1) = 0;
%         ae(end+1,1) = 0;
%         a = a(:);
%         ae = ae(:);
        
        ncol = size(a,2);
        nbar = size(a,1);
        for kk = 1:ncol
            subplot2([2 ncol], 1 + (kk-1)*2);
            hold on
            %Plot separate bars so we can color them individually
            arrayfun(@(x,y) bar(x,y), 1:nbar, a(:,kk)');
%             bar(a(:,kk))
            errorbar(a(:,kk), ae(:,kk), 'Color', 'k', 'LineStyle', 'none')
            if style == 1
                title( sprintf('%d', kk) )
            else
                title( sprintf('a_%d', kk) )
            end
            xlim([0 nbar+1])
            set(gca, 'XTickMode', 'manual')
            set(gca, 'XTick', 1:nbar)
            set(gca, 'XTickLabel', {inst.nam} )
            set(gca, 'XTickLabelRotation', 90)
        end
        
%         bar(a)
%         errorbar(a, ae, 'LineStyle', 'none')
%         title a
        
%         ax = subplot2([2 1], 2);
%         hold(ax, 'on')
%         xx = 1:maxi;
        %Reshape bars to be grouped with spaces
%         k(end+1,1) = 0;
%         ke(end+1,1) = 0;
%         k = k(:);
%         ke = ke(:);
        for kk = 1:ncol
            subplot2([2 ncol], 2 + (kk-1)*2);
            hold on
            arrayfun(@(x,y) bar(x,y), 1:nbar, k(:,kk)');
%             bar(k(:,kk))
            errorbar(k(:,kk), ke(:,kk), 'Color', 'k', 'LineStyle', 'none')
            title( sprintf('k_%d', kk) )
            xlim([0 nbar+1])
            set(gca, 'XTickMode', 'manual')
            set(gca, 'XTick', 1:nbar)
            set(gca, 'XTickLabel', {inst.nam} )
            set(gca, 'XTickLabelRotation', 90)
        end

%         bar(k)
%         errorbar(k, ke, 'LineStyle', 'none')
%         title a
%         title k

end










