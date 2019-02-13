function [transitions,fit] = StepFinding_SelectTransitions(data,sgn,param)
% Yann Chemla
% Modified 3/3/08 JM to give widths of transitions
% Modified 15 March 2011 by Gheorghe Chistol

threshhold = param(1);
if length(param) > 1
    win = param(2);
else
    win = 1;
end    

sgn = sgn(:)';

% -------------------method using minima of sgn
sgnm = sgn(2:end-1)-sgn(1:end-2);
sgnp = sgn(2:end-1)-sgn(3:end);
centeridx = find(sgnm < 0 & sgnp < 0 & sgn(2:end-1) <= threshhold)+1;

% if transitions are 2 or closer apart, combine and select more significant
idx = find(diff(centeridx) <= 1);
if sgn(centeridx(idx)) <= sgn(centeridx(idx+1))
    centeridx(idx+1) = centeridx(idx);
else
    centeridx(idx) = centeridx(idx+1);
end;
centeridx = unique(centeridx);

% -------------------calculate means between transitions
idx = [1 centeridx length(data)];
% in case centeridx(1) = 1 or centeridx(end) = length(data)
idx = unique(idx); 

above = find(sgn > threshhold); % find all regions above threshold

for j = 1:length(idx)-1
    if j == 1 % exception at start of trace
        meandwell(j) = mean(data(1:idx(j+1)-1));
        stddwell(j) = std(data(1:idx(j+1)-1));
        Ndwell(j) = idx(j+1)-1;
    elseif j == length(idx)-1 % exception at end of trace  
        meandwell(j) = mean(data(idx(j)+1:length(data)));
        stddwell(j) = std(data(idx(j)+1:length(data)));
        Ndwell(j) = length(data)-idx(j);
    else
        meandwell(j) = mean(data(idx(j)+1:idx(j+1)-1));
        stddwell(j) = std(data(idx(j)+1:idx(j+1)-1));
        Ndwell(j) = idx(j+1)-idx(j)-1;
    end    
    fit(idx(j):idx(j+1)) = meandwell(j);
    
    % Calculate widths
    [junk, posID] = sort([idx(j+1) above]);
    ind2 = find(posID==1);
    if ind2 == 1
        width(j) = above(1)-1;
    elseif ind2 == length(above)+1
        width(j) = length(sgn)-above(ind2-1);
    else
        width(j) = above(ind2) - above(ind2-1)-1;
    end
end;

% -------------------output structure
transitions.cidx = centeridx;
transitions.mean = meandwell;
transitions.std = stddwell;
transitions.Npts = Ndwell;
transitions.wid = width;
