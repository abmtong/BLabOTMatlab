function out = avgprotsV3(incell)
%Align prots by angular histogram
%Use output from getprotfromfigV2

histind = 3;
protind = 4;

len = size(incell, 1);

%Store angle offset here
angoff = zeros(1,len);
hst = cell(1,len);
prt = cell(1,len);

%Resample angle to this granularity. Should evenly divide 120 degrees.
dth = 1;
thx = (dth:dth:360)-dth;
n = length(thx);

%Interpolate using cyclic x: do by just repeating the data 3 times, one pre and one post.
interpcyc = @(x, y) interp1([x-360 x x+360], repmat(y, 1, 3), thx, 'spline');

for i = 1:len
    %Align by angular histogram
    %Get coords
    hstraw = incell{i,histind};
    prtraw = incell(i,protind);
    
    %Make sure we have both
    if isempty(hstraw) || isempty(prtraw)
        continue
    end
    
    %Interpolate to new dth. hst is 0-360, prt is 0-1
    hst{i} = interpcyc(hstraw(:,1), hstraw(:,2));
    prt{i} = interpcyc(prtraw(:,1)*360, prtraw(:,2));
    
    %Find best 3-fold axis
    method = 1;
    switch method
        case 1 %Add 3rot, then take largest peak
            h3 = sum(reshape(hst,[],3), 2);
            [~, maxi3] = max(h3);
            [~, maxtri] = max( hst(maxi3 + [0 n/3 2*n/3]) );
            angoff(i) = maxi3 + (maxtri-1) * n/3;
        case 2 %Just find the max value
            hstsm = smooth(hst, 5);
            [~, angoff(i)] = max(hstsm);
        otherwise
            angoff = 0;
    end
end

prtsum = zeros(1,n);
for i = 1:len
    %Now sum the protocols according to angoff
    prtsum = prtsum + circshift(prt{i}, [0 , 1-angoff]);
end






