function out = kinNumSolve(data, k1g, k2g)
%Numeric solve
%data = [t A B C ...]

if nargin == 0
    %Generate test data
    t = linspace(0,20,50);
    tmp = exp(-0.2*t); %Real coeff 0.2
    data = [t' tmp'+randn(size(tmp))'*.1 1-tmp'+randn(size(tmp))'*.1]; %add 0.1 noise
    %Lets set t=0 as 'assumed' amounts
    data(1,:) = [0 1 0];
    k1g = [0 2; 0 0]; %Guess of 2
    k2g = zeros(2,2,2);
end

t = data(:,1);
len = length(t);
dat = data(:,2:end);
wid = size(dat,2);

if nargin > 0 && nargin < 3 || isempty(k2g)
    k2g = zeros(wid, wid, wid);
end

if nargin > 0 && nargin < 2 || isempty(k1g)
    k1g = zeros(wid);
end



%Make dt, nT for numeric integration
%Say we want 100pts per input datapt
nT = len * 10;
dt = t(end) / nT;
nT = nT + 10; %Extend a bit past the last timept

%Make accessory vectors to assemble k1 from x0, the optimization value

ind1 = find(k1g(:) > 0)';
ind2 = find(k2g(:) > 0)';

ind = [ind1 ind2];
indh = [ones(size(ind1)) ones(size(ind2))];

nv = length(ind);

xg = [k1g(ind1) k2g(ind2)];
lb = zeros(1,nv);
ub = inf(1,nv);

ft = lsqcurvefit(@kinCurve, xg, t, dat, lb, ub);

[o1, o2] = getK(ft);
out = {o1 o2};

%And plot
figure, hold on
co = lines(7);
datfit = kinCurve(ft, t);
for i = 1:wid
    colind = mod(i-1, 7) + 1;
    col = co(colind,:);
    colli = (col + 2*ones(1,3)) /3;
    %Plot data in light o, data in solid color, thick line
    plot(t, dat(:,i) , 'o', 'Color', colli)
    plot(t, datfit(:,i) , 'Color', col, 'LineWidth', 1)
    
end

    function [k1, k2] = getK(x0)
        %Form k1, k2 mtx from x0
        k1 = zeros(wid,wid);
        k2 = zeros(wid,wid,wid);
        for ii = 1:nv
            if indh
                k1(ind) = x0(ii);
            else
                k2(ind) = x0(ii);
            end
        end
        
    end

    function out = kinCurve(x0,x)
        
        [k1, k2] = getK(x0);
        %Do kinNumInt
        y = kinNumInt(dat(1,:), k1, k2, dt, nT);
        %Resample
        out = interp1( (0:length(y)-1)*dt, y, x );
    end

end