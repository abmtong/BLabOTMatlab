function [indSta, indEnd] = thresh(dat, thr)
%Finds sections in data that are above thr, outputs their indicies such that each section
% is indSta(i):indEnd(i)
% To get regions below thr, do thresh(-data, -thr)

dtf = diff( [0 dat > thr 0] );
indSta = find(dtf > 0);
indEnd = find(dtf < 0) -1;