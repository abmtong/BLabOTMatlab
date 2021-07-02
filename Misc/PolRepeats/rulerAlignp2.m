function [out outraw] = rulerAlignp2(in, inOpts)
%Refines rulerAlign results, searching more finely over the previous results


%Use the output of rulerAlign, decrease persch and set start to 0

%Eh can still just use rulerAlignV2 here with a different opts struct