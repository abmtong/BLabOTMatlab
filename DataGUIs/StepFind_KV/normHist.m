function outHist = normHist(inData, inBinSize)
%Trying to move away from this and use nhistc instead

if nargin < 2
    inBinSize = 0.2;
end

N = length(inData);
%Find limits (make bins fall on nice values), pad with 5 pts on each end for fSH
lo = (floor(min(inData)/inBinSize)-5)*inBinSize;
hi = ( ceil(max(inData)/inBinSize)+5)*inBinSize;

%bins are centered at these values
bins = lo:inBinSize:hi;
nums = zeros(1,length(bins));
for i = 1:length(bins)
    nums(i) = sum( ((inData >= bins(i)-inBinSize/2) & (inData < bins(i)+inBinSize/2)) );
end
%         [Bin   Probability       Count]
outHist = [bins' nums'/N/inBinSize nums'];