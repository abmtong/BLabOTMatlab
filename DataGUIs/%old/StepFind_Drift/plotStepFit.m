function plotStepFit(inAxes, inTime, inMean, inInd)
% Plots a [time, contour] pair, its filter, and its step-found index

%Create index vectors
%indX = [1 2 2 3 3 4 4 .... end-1 end-1 end], end is w.r.t inInd
%indY = [1 1 2 2 3 3 4 4 ... end-1 end-1]
len = length(inInd);
indX =[1 reshape([2:len-1;2:len-1],1,[]) len];
indY = reshape([1:len-1; 1:len-1],1,[]);

lineX = inTime(inInd(indX));
lineY = inMean(indY);

hold(inAxes, 'on');
line(inAxes, lineX,lineY, 'Color', [0 0 0.5])
hold(inAxes, 'off');

end

