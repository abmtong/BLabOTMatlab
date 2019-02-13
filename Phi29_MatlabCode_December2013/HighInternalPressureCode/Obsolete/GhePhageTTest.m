function [trans, phageData] = GhePhageTTest(phages, param, phageData, options)
%This function calculates the T-test and saves that info in the phageData.
% Use this function instead of the one in the NewAnalysis folder
%
% Gheorghe Chistol, May 29, 2010

for i=1:length(phageData)
    phageInd(i) = phageData(i).phID;
    stepInd(i) = phageData(i).stID;
end

if nargin < 2           %if no parameters are indicated
    average = 10;
    win = 10;           %set an automatic window size
    threshhold = 1e-4;  %set an automatic threshhold
else
    average = param(1);
    win = param(2);
    threshhold = param(3);
end

if length(phages) == 1
    phages(1) = phages;
end

%------------------------------- Run main loop, filter data & calculate t-test
temp = 0;
count = 0;
sgn_min_all = []; stepsize_all = []; dwelltime_all = []; stepsize_select_all = []; 
std_select_all = []; wid_all =[];
for i = 1:length(phageInd)
    if temp ~= phageInd(i)
        display(['Calculating T Test for phage #' num2str(phageInd(i)) ': ' phages(phageInd(i)).file]);
    end


    %------------------------------- Filter and decimate data
    contour = filter(ones(1,average), average, phages(phageInd(i)).contour{stepInd(i)});
    contour = contour(average:average:end);
    phageData(i).contour=contour;
    time = phages(phageInd(i)).time{stepInd(i)};
    time = time(average:average:end);
    dt = time(2)-time(1);

    if length(contour) > win % only use data longer than t-test window
        %------------------------------- Calculate t and sgn
        [t, sgn] = TTestWindow(contour, win, 'CalSign');
        phageData(i).t = t';
        phageData(i).sgn = sgn';

        xav{i} = contour;
        tav{i} = time;

        %------------------------------- Find minima in sgn
        [trans(i), xfit{i}] = SelectTransitions(xav{i},phageData(i).sgn,[threshhold 1]);
        % Now outputs a width for each transition
        stepsize = diff(trans(i).mean);
        dwelltime = diff(trans(i).cidx)*dt;
        stepsize_select = stepsize(2:end);
        std_select = trans(i).std(2:(end-1));
        widths = trans(i).wid(2:(end-1))*dt;
        
        sgn_min_all = [sgn_min_all phageData(i).sgn(trans(i).cidx)];
        stepsize_all = [stepsize_all stepsize];
        stepsize_select_all = [stepsize_select_all stepsize_select];
        dwelltime_all = [dwelltime_all dwelltime];
        std_select_all = [std_select_all std_select];
        wid_all = [wid_all widths];
        phageData(i).chisq = var(xav{i}-xfit{i});
        
        % Export tav and xfit for easy use later
        % JM 01/29/08
        phageData(i).xfit = xfit{i};
        phageData(i).tfit = tav{i};
        
    end
    temp = phageInd(i);
end
t_all = [phageData.t];
sgn_all = [phageData.sgn];
trans_all.cidx = [trans.cidx];
trans_all.mean = [trans.mean];
trans_all.std = [trans.std];
trans_all.Npts = [trans.Npts];

%------------------------------- Calculate t, sgn & sgn min histograms
Btinc = 0.1;
Bt_all = floor(min(t_all)):Btinc:ceil(max(t_all));
Nt_all = hist(t_all,Bt_all);
Ntfit = gamma((win+1)/2)/(sqrt(win*pi)*gamma(win/2))*(1+Bt_all.^2/win).^(-(win+1)/2)*length(t_all)*Btinc;

Bsgninc = 0.1;
Bsgn_all = -0.05+floor(min(log10(sgn_all))):Bsgninc:0;
Nsgn_all = hist(log10(sgn_all),Bsgn_all);
Nsgnfit = exp(Bsgn_all)*Nsgn_all(end);

Btransinc = 0.1;
Btrans = -0.05+floor(min(log10(sgn_min_all))):Btransinc:0;
Ntrans = hist(log10(sgn_min_all),Btrans);

%------------------------------- Calculate step size and dwell time histograms
Bmeaninc = 0.2;
Bmeandwell = min(stepsize_all):Bmeaninc:max(stepsize_all);
Nmeandwell = hist(stepsize_all,Bmeandwell);

Bdwellinc = dt;
Bdwelltime = min(dwelltime_all):dt:max(dwelltime_all);
Ndwelltime = hist(dwelltime_all,Bdwelltime);

B2D{1} = Bdwelltime; B2D{2} = Bmeandwell;
%min(phageData.sgn)
dwellstep2D(:,1) = dwelltime_all; 
dwellstep2D(:,2) = stepsize_select_all;
%N2D = hist3(dwellstep2D,B2D);
%[B2Dx,B2Dy] = meshgrid(B2D{1},B2D{2});

%------------------------------- Plot results in first figure
%if strcmp(options,'plot') || strcmp(options,'plot1');
%    figure('Name',['T-test analysis 1. Averaging = ',num2str(average),', T-test window = ',num2str(win), ...
%        ', Threshhold = ',num2str(threshhold,'%1.1e')]);
%    subplot(2,2,1);
%    for i = 1:length(phageInd)
%        plot(tav{i},phageData(i).t,'b'); hold on;
%    end;
%    xlabel('time (s)');
%    ylabel('t value');

%    subplot(2,2,2);
%    for i = 1:length(phageInd)
%        plot(tav{i},log10(phageData(i).sgn),'b'); hold on;
%        plot(tav{i}(trans(i).cidx),log10(phageData(i).sgn(trans(i).cidx)),'g.');
%    end;
%    xlabel('time (s)');
%    ylabel('log(sgn value)');

%    subplot(2,2,3);
%    semilogy(Bt_all,Ntfit,'k-'); hold on;
%    stairs(Bt_all,Nt_all,'b-');
%    axis([-Inf Inf 0.1 Inf]);
%    xlabel('t value');
%    ylabel('count');

%    subplot(2,2,4);
%    semilogy(Bsgn_all,Nsgnfit,'k-'); hold on;
%    stairs(Bsgn_all,Nsgn_all,'b-');
%    plot(Btrans,Ntrans,'r.');
%    axis([-Inf Inf 0.1 Inf]);
%    xlabel('t value');
%    ylabel('count');
%end;

%------------------------------- Plot results in second figure
%if strcmp(options,'plot') || strcmp(options,'plot2');
%    figure('Name',['T-test analysis 2. Averaging = ',num2str(average),', T-test window = ',num2str(win), ...
%        ', Threshhold = ',num2str(threshhold,'%1.1e')]);
%    subplot(2,2,1);
%    for i = 1:length(phageInd)
%        plot(tav{i},xav{i},'b'); hold on;
%        %plot(tav{i}(trans(i).cidx),xav{i}(trans(i).cidx),'g.');
%        plot(tav{i},xfit{i},'r');
%    end
%    xlabel('time (s)');
%    ylabel('contour (bp)');

%    subplot(2,2,2);
    %plot(stepsize_select_all,dwelltime_all,'b.');
%    pcolor(B2Dx,B2Dy,N2D'); colormap('hot');
%    shading flat;
%    xlabel('time (s)');
%    ylabel('step size (bp)');

%    subplot(2,2,3);
%    stairs(Bmeandwell,Nmeandwell,'b'); hold on;
%    axis([min(Bmeandwell) max(Bmeandwell) 0 1.5*max(Nmeandwell)]);
%    xlabel('step size (bp)');
%    ylabel('count');

%    subplot(2,2,4);
%    stairs(Bdwelltime,Ndwelltime,'b'); hold on;
%    temp = hist(trans_all.Npts*dt,Bdwelltime);
%    stairs(Bdwelltime,temp,'r');
%    xlabel('Dwell time');
%    ylabel('Count');
%end;

%------------------------------- Plot results in third figure
if strcmp(options,'plot') || strcmp(options,'plot3');
    figure('Name',['T-test analysis 3. Averaging = ',num2str(average),', T-test window = ',num2str(win), ...
        ', Threshhold = ',num2str(threshhold,'%1.1e')]);
    xav_all = [];
    subplot(1,2,1);
    for i = 1:length(phageInd)
        for j = 1:length(trans(i).cidx)
            startidx = (trans(i).cidx(j)-average); 
            if startidx <= 0 
                startidx = 1; 
            end;
            endidx = (trans(i).cidx(j)+average);
            if endidx > length(xav{i}) 
                endidx = length(xav{i});
            end;         
            xav_all = [xav_all xav{i}(startidx:endidx)-xav{i}(trans(i).cidx(j))];
            plot(tav{i}(startidx:endidx)-tav{i}(trans(i).cidx(j)),xav{i}(startidx:endidx)-xav{i}(trans(i).cidx(j)),color(i,'.-'));
            hold on;
        end;    
    end;    
    subplot(1,2,2);
    [n,bin] = hist(xav_all,100);
    stairs(n,bin,'r');
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remove the unnecessary fields, rename some fields
for p=1:length(phageData)
    phageData(p).time = phageData(p).tfit; %time corresponding to the contour data
    phageData(p).contourFit = phageData(p).xfit; %rename these fields
    phageData(p).timeFit = phageData(p).tfit; %rename these fields
end
    Fields={'velocity' 'std' 'contourStart' 'contourEnd' ...
        'contourAv' 'hist' 'bin' 'filter' 'binsize' 'rank' 'start' ...
        'end' 'fft' 'freq' 'peak' 'visibleSteps' 'paused' 'contOffset' ...
        'timeAv' 'timeStart' 'timeEnd' 'chisq' 'xfit' 'tfit' 'numPoints' 'forceErr'};
    for i=1:length(Fields)
        phageData=rmfield(phageData, Fields(i));
    end
    %disp('Cleaned up phageData');
