function out = getstep2Tyson(data,plotopt)
%Data is column vector of y-values, plotopt = 1 if you want plots

% Find maximum and minimum of data
dmin=min(data);
dmax=max(data);
 
% Establish PDF via finite difference CDF
cumudist=cdf(data,dmin,dmax);
fdcdf=findif(cumudist);
if plotopt==1, figure(9), plot(fdcdf(:,1),fdcdf(:,2),'r-'), hold on, end;
if plotopt==1, figure(9), plot(fdcdf(:,1),del2(fdcdf(:,2)),'g-'), hold on, end;
% Sum PDF and 2nd derivative of PDF
fdcdf(:,2)=(fdcdf(:,2)+del2(fdcdf(:,2)));
if plotopt==1, figure(9), plot(fdcdf(:,1),fdcdf(:,2),'m-'), hold on, end;
% Square of PDF+PDF''
fdcdf(:,2)=fdcdf(:,2).^2;
if plotopt==1, figure(9), plot(fdcdf(:,1),fdcdf(:,2),'b-'), hold on, end; 
sigsum(:,1)=cumudist(:,1);
% Perform Local Extrema Interpolation Averaging to smooth high frequency
% noise
sigsum(:,2)=leia(fdcdf);
if plotopt==1, figure(9), plot(sigsum(:,1),sigsum(:,2),'k-'), end;
 
% Find peaks in resulting signal
steps1=findpeaks(sigsum);
 
if ~isempty(steps1),
    steps1=data(dsearchn(data,steps1'));
    steps1=sort(steps1);   
    % Plot data signal with detected steps
    if plotopt==1,
        figure(3);
        hold on;
        xmax=length(data(:,1));
        for i=1:length(steps1),
            if steps1(i)~=0,
                b=steps1(i);
                plot([0 xmax],[b,b],'Color','k');
            end;
        end;
        plot(data(:,1),'b-');
        hold off;
    end
end
 
out.data=data;
out.steps1=steps1;
out.cdf=cumudist;
out.fdcdf=fdcdf;
out.sigsum=sigsum;
 
end
 
function out = cdf(data,dmin,dmax)
% This function calculates the cumulative distribution function
 
temp=diff(data);
avgtemp=mean(abs(temp));
stdtemp=std(abs(temp));
ind=avgtemp/stdtemp;
val=dmin-rand(1);
k=1;
while val<=dmax+ind,
    out(k,1)=val;
    out(k,2)=sum(data<val);
    val=val+ind;
    k=k+1;
end
 
end
 
function out = findif(data)
% This function performs a finite difference calculation

out=zeros(length(data),2);
out(:,1)=data(:,1);
for i=1:length(data)-1,
    dx=data(i+1,1)-data(i,1);
    dy=data(i+1,2)-data(i,2);
    out(i,2)=dy/dx;
end
 
end
 
function [xmax,imax,xmin,imin] = extrema(x)
% This function analyzes a signal to determine local extrema (value and
% location)
 
xmax = [];
imax = [];
xmin = [];
imin = [];
 
Nt = numel(x);
if Nt ~= length(x)
 error('Entry must be a vector.')
end
 
inan = find(isnan(x));
indx = 1:Nt;
if ~isempty(inan)
    indx(inan) = [];
    x(inan) = [];
    Nt = length(x);
end
 
% Difference between subsequent elements:
dx = diff(x);
 
if ~any(dx)
    return
end
 
% Flat peaks are associated with the middle of that section
a = find(dx~=0);              
lm = find(diff(a)~=1) + 1;    
d = a(lm) - a(lm-1);          
a(lm) = a(lm) - floor(d/2);   
a(end+1) = Nt;
 
% Determine other peaks
xa  = x(a);             
b = (diff(xa) > 0);     
xb  = diff(b);          
imax = find(xb == -1) + 1; % maxima indexes
imin = find(xb == +1) + 1; % minima indexes
imax = a(imax);
imin = a(imin);
 
nmaxi = length(imax);
nmini = length(imin);                
 
% Analyze the boundaries of the signal
if (nmaxi==0) && (nmini==0)
 if x(1) > x(Nt)
  xmax = x(1);
  imax = indx(1);
  xmin = x(Nt);
  imin = indx(Nt);
 elseif x(1) < x(Nt)
  xmax = x(Nt);
  imax = indx(Nt);
  xmin = x(1);
  imin = indx(1);
 end
 return
end
 
% Maximum or minumim at the ends
if (nmaxi==0) 
 imax(1:2) = [1 Nt];
elseif (nmini==0)
 imin(1:2) = [1 Nt];
else
 if imax(1) < imin(1)
  imin(2:nmini+1) = imin;
  imin(1) = 1;
 else
  imax(2:nmaxi+1) = imax;
  imax(1) = 1;
 end
 if imax(end) > imin(end)
  imin(end+1) = Nt;
 else
  imax(end+1) = Nt;
 end
end
xmax = x(imax);
xmin = x(imin);
 
% Clean up NaNs
if ~isempty(inan)
 imax = indx(imax);
 imin = indx(imin);
end
 
imax = reshape(imax,size(xmax));
imin = reshape(imin,size(xmin));
 
% Sort results
[~,inmax] = sort(-xmax);
xmax = xmax(inmax);
imax = imax(inmax);
[xmin,inmin] = sort(xmin);
imin = imin(inmin);
 
end
 
function peeks1 = findpeaks(signal)
% This function analyzes the final signal to determine likely peaks that
% correspond to significant steps/dwells
 
peeks1=[];
ydata=signal(:,2);
dev=std(ydata);
 
[~,imax,~,imin]=extrema(ydata);
 
% Optional diagnostic plotting
% figure(2), plot(signal(:,1),signal(:,2),'r-'), hold on;
% figure(2), plot(signal(imax,1),xmax,'kx'), hold on;
% figure(2), plot(signal(imin,1),xmin,'go'), hold on;
 
imin=sort(imin);
imax=sort(imax);
 
diffarr=zeros(length(imax),3);
pathint=zeros(length(imax),4);
 
for i=1:length(imax),
    
    % Find boundaries of peaks -- minimum on each side
    indleft=find(imin<imax(i),1,'last');
    indrite=find(imin>imax(i),1,'first');
    
    % Find elements from each minimum to the maximum
    lpath=signal(imin(indleft):imax(i),:);
    rpath=signal(imax(i):imin(indrite),:);
    
    % Calculate arc length
    pathint(i,1)=signal(imax(i),1);
    pathint(i,2)=pathcalc(lpath);
    pathint(i,3)=pathcalc(rpath);
    pathint(i,4)=mean(pathint(i,2:3));
    
    % Peaks at boundaries may have only one minimum
    left=ydata(imin(indleft));
    if isempty(left),
        left=0;
    end
    rite=ydata(imin(indrite));
    if isempty(rite),
        rite=0;
    end
    
    % Collect arc lengths for each peak
    diffarr(i,1)=signal(imax(i),1);
    diffarr(i,2)=abs(ydata(imax(i))-left);
    diffarr(i,3)=abs(ydata(imax(i))-rite);
end
 
% Optional diagnostic plotting
% figure(2), plot(pathint(:,1),pathint(:,2),'-bd'), hold on;
% figure(2), plot(pathint(:,1),pathint(:,3),'-md'), hold on;
 
k=1;
for i=1:length(imax),
    if diffarr(i,2)>dev,
        j=0;
        if diffarr(i,3)>dev,
            peeks1(k)=diffarr(i,1);
            k=k+1;
        end
        if diffarr(i,3)<=dev,
            while diffarr(i+j,3)<dev,
                if (i+j)<length(imax),
                    j=j+1;
                else
                    break;
                end
            end
            peeks1(k)=mean(diffarr(i:(i+j),1));
            k=k+1;
        end
    end
end
 
end
 
function out = pathcalc(data)
% This function calculates the arc length for the discrete input data using
% quadrature
 
xdata=data(:,1);
ydata=data(:,2);
 
pathsum=0;
for i=1:length(ydata)-1,
    dist=sqrt((xdata(i+1)-xdata(i))^2+(ydata(i+1)-ydata(i))^2);
    fd=(ydata(i+1)-ydata(i))/(xdata(i+1)-xdata(i));
    avg=(ydata(i+1)+ydata(i))/2;
    pathsum=pathsum+(abs(fd)*avg*dist);
end
 
out=pathsum;
 
end
 
function out=leia(data)
% This function performs Local Extrema Interpolation Averaging
 
[xmax,imax,xmin,imin]=extrema(data(:,2));
maxfunc=interp1(data(imax),xmax,data(:,1),'cubic');
minfunc=interp1(data(imin),xmin,data(:,1),'cubic');
 
for i=1:length(maxfunc),
    if isnan(maxfunc(i)),
        k=dsearchn(maxfunc,maxfunc(i));
        maxfunc(i)=maxfunc(k);
    end
    if isnan(minfunc(i)),
        k=dsearchn(minfunc,minfunc(i));
        minfunc(i)=minfunc(k);
    end
end
 
out=(0.5)*(maxfunc+minfunc);
 
% Optional diagnostic plotting
% figure(4), plot(data(:,1),data(:,2),'r-'), hold on;
% figure(4), plot(data(:,1),maxfunc,'b-'), hold on;
% figure(4), plot(data(:,1),minfunc,'g-'), hold on;
% figure(4), plot(data(:,1),out,'k-');
 
end
