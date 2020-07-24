function [outInd, outMea, outTra] = FindStepDWT_ttr( inContour, inIters, inThresh, silent )

if nargin < 4
    silent = 0;
end

%"Prominence", see >> doc findpeaks
if nargin < 3 || isempty(inThresh)
    inThresh = .01;
end

if nargin < 2 || isempty(inIters)
    inIters = 8;
end


inds = cell(length(inIters),length(inThresh));
index1 = 1;
for i = inIters
    [dwt, res] = mal_fwt(i, inContour);
    index2 = 1;
    for j = inThresh
        figure('Name',sprintf('DWT iter %d thresh %d',i,j))
        
        ax1 = subplot(2, 1, 1);
        [~, ind] = findpeaks(-double(dwt(:,i)),'MinPeakProminence',j);
        if ~silent
            findpeaks(-double(dwt(:,i)),'MinPeakProminence',j);
        end
        ind = [1 ind' length(inContour)];
        ind = ind([true diff(ind)>25]);
        mea = ind2mea(ind, inContour);
        tra = ind2tra(ind, mea);
        
        ax2 = subplot(2, 1, 2);
        hold on
        plot(inContour, 'Color', [.8 .8 .8])
        plot(res, 'Color', [.4 .4 .4])
        %plot(windowFilter(@mean, inContour, 12,1),'Color', [.4 .4 .4])
        plot(tra, 'Color', 'b')
        hold off
        
        linkaxes([ax1 ax2], 'x')
        
        fprintf('DWT: [%d,%d] found %d steps over %0.2f bp\n', i, j, length(mea)-1, mea(1)-mea(end))
        
        inds{index1,index2} = ind;
        index2 = index2 + 1;
    end
    index1 = index1 + 1;
end

if length(inds) > 1
    num1 = [];
    num2 = [];
    while isempty(num1) || isempty(num2)
        fprintf('View graphs, press any key when ready\n')
        pause
        num = input('Which [iter, thresh]? ');
        if ~isnumeric(num) && length(num) < 2
            continue;
        end
        if isempty(num)
            return;
        end
        num1 = find(inIters == num(1));
        num2 = find(inThresh == num(2));
    end
    outInd = inds{num1,num2}; 
else
    outInd = inds{1};
end

outMea = ind2mea(outInd, inContour);
outTra = ind2tra(outInd, outMea);
