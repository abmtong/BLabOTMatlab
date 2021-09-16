function outData = windowFilter( filterFcn, inData, inHalfWidth, inDecimate )
%Filters inData with a centered window with inWidth points on each side, taking every inDecimate points
%@filterFcn must follow: filteredX(i) = filterFcn(X(windowInds)), e.g. @mean or @median, or use as shortcut for @var, etc.

narginchk(3,4)

%Default decimation factor
if nargin < 4 || isempty(inDecimate)
    inDecimate = 1;
end

%if input data is cell, batch
if iscell(inData)
    outData = cellfun(@(x) windowFilter(filterFcn, x, inHalfWidth, inDecimate), inData, 'un', 0);
    return
end

%input must be vector
if size(inData,1)~=1
    inData = inData(:)';
    warning('@windowFilter requires a 1xn vector input: ''%s'' has been reshaped to a row vector', inputname(2))
end

%Catch empty vectors
if isempty(inData)
    outData = [];
    return
end

%If just decimating, short circuit
if inHalfWidth == 0
    outData = inData(inDecimate:inDecimate:end);
    return
end

%Override for @mean to use @filter (implementation taken from @smooth)
% Could also do this for other filters that can use @filter, but edge cases need to be different
%  I don't use non-@mean filters anyway, so w/e
% Not using @smooth because that requires a toolbox
%Might be slower if inDecimate / trace is large, bc filters the whole thing first?
if isequal(filterFcn, @mean)
    %if filtering and decimating, use a different algorithm (not @smooth) for speed
    % This shifts points from edges to centers, but eh it'll be consistent
    if isempty(inHalfWidth)
%         inHalfWidth = floor((inDecimate - 1) / 2 ) + 1;
        outData = mean( reshape( inData(1: floor((length(inData)/inDecimate))*inDecimate), inDecimate, [] ), 1 );
        return
    end
    if inHalfWidth * 2 - 1 > length(inData)
        inHalfWidth = max(length(inData) / 2 - 1,0);
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