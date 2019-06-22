function outData = windowFilter( filterFcn, inData, inWidth, inDecimate )
%Filters inData with a centered window with inWidth points on each side, taking every inDecimate points
%@filterFcn must follow: filteredX(i) = filterFcn(X(windowInds)), e.g. @mean or @median, or use as shortcut for @var, etc.
%ver 072718

narginchk(3,4)

%input must be vector
if ~isvector(inData)
    inData = inData(:)';
    warning('@windowFilter requires a vector input: ''%s'' has been reshaped to a row vector', inputname(2))
end

%Default decimation factor
if nargin < 4 || isempty(inDecimate)
    inDecimate = 1;
end

%If just decimating, short circuit
if inWidth == 0
    outData = inData(inDecimate:inDecimate:end);
    return
end

%Override for @mean, as matlab's is slow (checks for too many cases)
if isequal(filterFcn, @mean)
    filterFcn = @(x) sum(x)/length(x);
end

%Calculate the output length, preserve size and type
len = length(inData);
outData = zeros(max(floor(size(inData)/inDecimate), [1 1]), class(inData));
outlen = length(outData);

if len < inDecimate %short circuit, probably unnecessary
    outData = filterFcn(inData);
    return
end

if isempty(inWidth) %filter and decimate to same length
    for i = 1:outlen
        outData(i) = filterFcn(inData((i-1)*inDecimate+1:i*inDecimate));
    end
    return
end

for i = 1:outlen
    %The point in inData that this corresponds to
    pos = i*inDecimate;
    %Handle bdy indices, if 2*inWidth+1 is larger than inDecimate
    startInd = max(1,pos-inWidth);
    endInd = min(pos+inWidth, len);
    %Apply filter
    outData(i) = filterFcn(inData(startInd:endInd));
end