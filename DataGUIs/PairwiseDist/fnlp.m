function fnlp(inx, iny, option)
%Find aNd Label Peaks

if nargin < 3
    option = 0; %plot differences between peaks
    %option = 1 > plot locations of peaks
end

if nargin < 2
    iny = inx;
    inx = 1:length(iny);
    name = inputname(1);
else
    name = inputname(2);
end

inx = double(inx);
iny = double(iny);

[pk, lc] = findpeaks(iny);%, 'MinPeakProminence', 0.0001);

figure('Name', sprintf('FNLP %s', name))
plot(inx, iny)
hold on
plot(inx(lc), pk, 'o')

if option == 0
    for i = 1:length(pk)-1
        text( mean(inx(lc(i:i+1))), mean(pk(i:i+1)), sprintf('%0.2f', diff(inx(lc(i:i+1)))) )
    end
elseif option == 1
    for i = 1:length(pk)
        text( inx(lc(i)), pk(i), sprintf('%0.2f', inx(lc(i))) )
    end 
end