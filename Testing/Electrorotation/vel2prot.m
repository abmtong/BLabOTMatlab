function out = vel2prot(pos, vel, method)

if nargin < 3
    method = 1;
end

%make sure pos <= 1/3
% assert(all(pos < 1/3), 'Pos must be <= 1/3')
last = round (max(pos) * 3 ) / 3;
%can probably just change the interp method to make case 1 and 2 the same (nearest vs. linear)

switch method
    case 1 %constant vel, change at midpoint between pos-es
        bdys = [0 (pos(1:end-1) + pos(2:end))/2 last];
        db = diff(bdys);
        dts = db./vel;
        ts = [0 cumsum(dts)];
        
        out = [ts(1:end-1)'/ts(end) pos'];
    case 2 %vel is linearly interpolated, sample every degree
        bdys = [-median(diff(pos)) 0 (pos(1:end-1) + pos(2:end))/2 last];
        vels = [vel(end) vel(1) vel];
        dth = 1;
        th = ((dth:dth:last*360)-dth)/360;
        vs = interp1(bdys, vels, th);
        dts = dth./vs;
        ts = [0 cumsum(dts)];
        th = [th last];
        out = [ts' th'];
end
