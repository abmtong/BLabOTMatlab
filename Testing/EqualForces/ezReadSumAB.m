function ezReadSumAB()
%Plots SumA and SumB from cal files

%Select files
[file, path] = uigetfile('C:\Data\RawData\*.dat','Pick your file(s)','MultiSelect','on');
if ~path %no file selected
    return
end
if ~iscell(file)
    file = {file};
end

len = length(file);
m = zeros(1,len);
b = zeros(1,len);
for i = 1:len
    cal = processHiFreq(path, file{i});
    sa = cal.SA;
    sb = cal.SB;
    
    figure('Name',file{i})
    plot(sa)
    hold on
    plot(sb)
    m(i) = mean(sa);
    b(i) = mean(sb);
end
fprintf('SumA=%0.2f+-%0.2f, SumB=%0.2f+-%0.2f\n', mean(m),std(m), mean(b),std(b))