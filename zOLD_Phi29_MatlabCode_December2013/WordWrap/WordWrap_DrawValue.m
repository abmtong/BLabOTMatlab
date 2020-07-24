function Value = WordWrap_DrawValue(Mean,StdFract)
% StdFract is given as a fraction relative to the Mean. The output Value
% is given in the same units as Mean 
%
% USE: Value = WordWrap_DrawValue(Mean,StdFract)
%
% gheorghe chistol, 19 Feb 2013

    Value = Mean*(1+2*(rand-0.5)*StdFract);
end