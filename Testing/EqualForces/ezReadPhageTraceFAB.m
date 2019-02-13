function ezReadPhageTraceFAB()
%Plots a bunch of ForceExtension/phage*.mat files on separate figures, plots -A and B force

%Select files
[file, path] = uigetfile('C:\Data\Analysis\*.txt','Pick your MATLABanalysis.txt file');
if ~path %no file selected
    return
end
filepath = [path filesep file];

%Based off code from AlexCreateAnalysisFile
fid = fopen(filepath);
tscan = textscan(fid, '%s %s %s');
fclose(fid);
datfile = tscan{1};
offfile = tscan{2};
calfile = tscan{3};
datemmddyy=datfile{1}(1:end-3); %MMDDYYN## to MMDDYY

datpath = [path '..' filesep '..' filesep 'RawData' filesep datemmddyy filesep];
len = length(datfile);
for i = 1:len
    %Load files
    load([path filesep calfile{i} '.mat']); %Becomes struct cal
    load([path filesep offfile{i} '.mat']); %Becomes struct offset
    d = processDat([datpath filesep datfile{i} '.dat']);
    %Smooth offset
    %While Ghe names his variable offset.A_X, it's really ax/sa (normalized units)
    offmx = smooth(offset.Mirror_X, 'rlowess');
    offax = smooth(offset.A_X, 'rlowess');
    offbx = smooth(offset.B_X, 'rlowess');
    offay = smooth(offset.A_Y, 'rlowess');
    offby = smooth(offset.B_Y, 'rlowess');
    
    [offmx, ind, ~] = unique(offmx); %Remove duplicate x values (else interp1 throws an error)
    offax = offax(ind);
    offbx = offbx(ind);
    offay = offay(ind);
    offby = offby(ind);
    %Calculate Force = (ax/sa-offset)*a*k
    fa  = -(d.ax ./ d.sa - interp1(offmx, offax, d.mx)) * cal.alphaAX * cal.kappaAX;
    fb  =  (d.bx ./ d.sb - interp1(offmx, offbx, d.mx)) * cal.alphaBX * cal.kappaBX;
    fay = -(d.ay ./ d.sa - interp1(offmx, offay, d.mx)) * cal.alphaAY * cal.kappaAY;
    fby =  (d.by ./ d.sb - interp1(offmx, offby, d.mx)) * cal.alphaBY * cal.kappaBY;
    figure('Name',datfile{i})
    ax1 = subplot(3,1,[1 2]);
    plot(fa)
    hold on
    plot(fb)
    plot(fb-fby+fab)
    line([0, length(fa)], [0, 0])
    ax2 = subplot(3,1,3);
    plot(fay)
    hold on
    plot(fby)
    line([0, length(fa)], [0, 0])
    linkaxes([ax1 ax2],'x')
end