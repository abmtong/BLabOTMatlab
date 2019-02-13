function tRating = filterByPWD(inData, filspan, bin)
%Takes in cell of traces inData calc.s PWD at a given 

if nargin < 3
    bin = 0.25;
end

if nargin<2
    filspan = 20;
end

if ~iscell(inData)
    inData = {inData};
end

if ~isa(inData{1}, 'double')
    inData = cellfun(@double,inData,'uni',0);
end
len = length(inData);
tRating = zeros(1,len);
fig = figure('Position',[0 0 1000 500]);
%hold on
ax = axes;
for i = 1:len
    cla(ax)
    %filter
    dfil = smooth(inData{i},filspan);
    [p, x] = calcPWD(dfil, bin);
    %p = smooth(p,10);
    [pks, loc] = findpeaks(p, x, 'MinPeakProminence', 1e-2);
    %findpeaks(p, x, 'MinPeakProminence', 1e-2)
    plot(x,p);
    if ~isempty(pks)
        pks = [pks(1) pks'];
        loc = [0 loc];
        sz = diff(loc);
        for j = 1:length(sz);
            text(mean(loc(j:j+1)), mean(pks(j:j+1)), sprintf('%0.1f',sz(j)));
        end
    end
    
    ind = find(diff(p)>0, 1);
    ax.YLim = [min(p(ind:end)), max(p(ind:end))];
    ax.XLim = [0 30];
    fig.Name = sprintf('filterByPWD: Trace %d of %d', i,len);
    drawnow
    
    resp = input(sprintf('Rate trace %d of %d: ',i,len),'s');
    %Pick first numeric response
    indnum = regexp(resp, '[0-9]');
    if isempty(indnum)
        fprintf('No numeric input for trace %d, assigning -1\n', i)
        tRating(i) = -1;
    else
        tRating(i) = str2double(resp(indnum(1)));
    end
%     switch questdlg('Keep Trace?', , 'Yes', 'No', 'Yes')
%         case 'No'
%             keepind(i) = false;
%     end
end

end

%Rough Rating System
%1: Don't use - weak peaks, weird pwd, etc.
%2: Medium peaks, uncorrelated
%3: Discernible pattern, medium peaks
%4: Clear pattern, medium peaks
%5: Clear, strong peaks

