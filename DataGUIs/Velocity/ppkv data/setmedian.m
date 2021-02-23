function setmedian(meds)

ax = gca;
ch = ax.Children;

%Assumes we have line/patch/line/patch/etc.

for i = 1: length(meds)
    %Get the two parts
    lne = ch(2*(i-1)+1);
    pat = ch(2*i);
    
    %Identify which graph we are on
    ind = round(mean(lne.XData));
    
    %Set line YData
    lne.YData = meds(i) * [1 1];
    
    %Match width
    xx=pat.XData(1:floor(end/2));
    yy = pat.YData(1:floor(end/2));
    wid = interp1(yy,xx-ind, meds(ind));
    lne.XData = ind + wid*[-1 1];
    
end