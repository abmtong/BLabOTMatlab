function varargout = sumPWDV1b(inData, filspan, bin, pfilspan, tfsgolay)
%argout  = [outPWD, outX]
%Takes in cell of traces inData calc.s PWD

%Current progress
%Just 2nd deriv seems to be useless (overvalues high frequency too much - see only artifacts)
%Binsize doesn't really matter, smaller just takes more time (too large and you lose precision)

if nargin < 5
    tfsgolay = 0;
end

if nargin < 4
    pfilspan = 3;
end

if nargin < 3
    bin = 0.2;
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
figure('Name', sprintf('sumPWD dat:%s fil:%d bin:%0.2f', inputname(1), filspan, bin), 'Position',[0 0 1000 500]);

wid = 50;
pts = round(wid/bin+1);

outX = 0:bin:wid;
outPWD = zeros(1,pts);

for i = 1:len
    %check for NaN (Ghe code had some NaN, bc some F is negative)
    if any(isnan(inData{i}))
        if all(isnan(inData{i}))
            continue
        else %rm nans if there is non-nan data
            inData{i} = inData{i}( ~isnan(inData{i}) );
        end
    end
    %filter
    if tfsgolay
        dfil = sgolayfilt(inData{i}, 1, filspan + ~mod(filspan,2) );
    else
        dfil = windowFilter(@mean, inData{i}, filspan, 1);
    end
%     dfil = windowFilter(@mean, inData{i}, [], filspan*2+1);
    [p, ~] = calcPWDV1b(dfil, bin);
    %     p = smooth(p,10);
    %     p = p';
%     p = windowFilter(@mean, p, pfilspan, 1);
    p = windowFilter(@mean, p, pfilspan, 1);
    
    if length(p) < pts
        p = [p p(end)*ones(1,pts)]; %#ok<AGROW>
    end
    outPWD = outPWD + p(1:pts);
end
%findpeaks(outPWD, outX)
plot(outX,outPWD)
[pk, lc] = findpeaks(outPWD, outX);
for i = 1:length(pk)
    text(lc(i), pk(i), sprintf('%0.2f',lc(i)))
end
ind = find(diff(outPWD)>0, 1);
if isempty(ind)
    ind = min(5, length(outPWD));
end
ylim([min(outPWD(ind:end)), eps+max(outPWD(ind:end))])
xlim([0 outX(end)])

if nargout > 2 %autocorr the autocorr
    outPWD2 = real(ifft(abs(fft(outPWD)).^2));
    outPWD2 = outPWD2(1:floor(end/2)) / outPWD2(1);
    outX2 = bin*(0:length(outPWD2)-1);
    hold on
    %scale outPWD2 to be the same ish
    outPWD2plot = outPWD2 * (range(ylim)) / range(outPWD2);
    outPWD2plot = outPWD2plot - mean(outPWD2plot) + mean(ylim);
    plot(outX2, outPWD2plot)
    varargout = {outPWD, outX, outPWD2, outX2, outPWD2plot};
else
    varargout = {outPWD, outX};
end
varargout = varargout(1:nargout);

