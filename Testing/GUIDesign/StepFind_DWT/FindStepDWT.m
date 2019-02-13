function [outInd, outMea, outTra] = FindStepDWT( inContour, inIters, inThresh, silent )

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
        [~, ind] = findpeaks(-double(dwt(:,i)),'MinPeakProminence',j);
        ind = [1 ind' length(inContour)];
        ind = ind([true diff(ind)>25]);
        mea = ind2mea(ind, inContour);
        tra = ind2tra(ind, mea);
        if ~silent
            figure('Name',sprintf('DWT iter %d thresh %d',i,j))
            ax1 = subplot(2, 1, 1);
            findpeaks(-double(dwt(:,i)),'MinPeakProminence',j);
            ax2 = subplot(2, 1, 2);
            hold on
            plot(inContour, 'Color', [.8 .8 .8])
            plot(res, 'Color', [.4 .4 .4])
            %plot(windowFilter(@mean, inContour, 12,1),'Color', [.4 .4 .4])
            plot(tra, 'Color', 'b')
            hold off
            linkaxes([ax1 ax2], 'x')
        end
        
        if ~isempty(mea)
            fprintf('DWT: [%d,%0.2f] found %d steps over %0.2f bp\n', i, j, length(mea)-1, mea(1)-mea(end))
        else
            fprintf('DWT: [%d,%0.2f] found %d steps over %0.2f bp\n', i, j, 0,0)
        end
        
        inds{index1,index2} = ind;
        index2 = index2 + 1;
    end
    index1 = index1 + 1;
end

if length(inds) > 1
    fprintf('View graphs, rerun with one [iter, thresh] to get output\n')
end

if nargout > 0
    outInd = inds{1};
    outMea = ind2mea(outInd, inContour);
    outTra = ind2tra(outInd, outMea);
end