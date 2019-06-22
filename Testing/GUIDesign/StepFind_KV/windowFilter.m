function outData = windowFilter( filterFcn, inData, inHalfWidth, inDecimate )
%Filters inData with a centered window with inWidth points on each side, taking every inDecimate points
%@filterFcn must follow: filteredX(i) = filterFcn(X(windowInds)), e.g. @mean or @median, or use as shortcut for @var, etc.
%ver 062019: added @filter for @mean

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

%Override for @mean to use @filter (implementation taken from @smooth)
% Not using @smooth because that requires a toolbox
if isequal(filterFcn, @mean)
    %if inHalfWidth is empty, use inDec
    if isempty(inHalfWidth)
        inHalfWidth = floor(inDecimate/2);
    end
    width = 2*inHalfWidth+1;
    len=length(inData);
    outData = filter(ones(1,width)/width,1,inData);
    oDsta = cumsum(inData(1:width-2));
    oDsta = oDsta(1:2:end)./(1:2:(width-2));
    oDend = cumsum(inData(len:-1:len-width+3));
    oDend = oDend(end:-2:1)./(width-2:-2:1);
    outData = [oDsta outData(width:end) oDend];
    outData = outData(inDecimate:inDecimate:end);
    return
end

%If just decimating, short circuit
if inHalfWidth == 0
    outData = inData(inDecimate:inDecimate:end);
    return
end


%Calculate the output length, preserve size and type
len = length(inData);
outData = zeros(max(floor(size(inData)/inDecimate), [1 1]), class(inData));
outlen = length(outData);

if len < inDecimate %short circuit, probably unnecessary
    outData = filterFcn(inData);
    return
end

if isempty(inHalfWidth) %filter and decimate to same length
    for i = 1:outlen
        outData(i) = filterFcn(inData((i-1)*inDecimate+1:i*inDecimate));
    end
    return
end

for i = 1:outlen
    %The point in inData that this corresponds to
    pos = i*inDecimate;
    %Handle bdy indices, if 2*inWidth+1 is larger than inDecimate
    startInd = max(1,pos-inHalfWidth);
    endInd = min(pos+inHalfWidth, len);
    %Apply filter
    outData(i) = filterFcn(inData(startInd:endInd));
end