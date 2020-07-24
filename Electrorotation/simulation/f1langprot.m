function [fr, ac] = f1langprot()

%Trap angles to use
thsamp = 1; %degrees
%Time to simulate
tsamp = 1;
%N to average over
tsampn = 10;

th = thsamp:thsamp:360;
th = th / 360 * 2 * pi; %deg > rad
n=length(th);
fr = cell(1,n);
ac = cell(1,n);

fopts = [];
fopts.dt = 2.5e-4; %Match sampling of camera
fopts.tmax = tsamp;

tfit = 0.01;
nfit = tfit / fopts.dt +1;
nfit = 11;

fprintf(['[' repmat('|', 1, n/10) ']\n'])
fprintf('[')
parfor i = 1:n
    tp = [0 th(i); tsamp th(i)];
    
    ta = cell(1,tsampn);
    tmp = zeros(1,tsampn);
    fo = fopts;
    fo.x0 = th(i);
    
    for j = 1:tsampn
        xt = f1lang(tp,fo);
        xt = xt(100:end);
        xt = xt-mean(xt);
        
        %V1
        [ta{j}, tmp(j)] = acrlv(xt, nfit);
        %V2
%         ta{j} = acrlv(xt, nfit);
%         tmp(j) = sum(ta{j});
        

%         if tmp(j) > .6e-4
%             tmp(j) = NaN;
%             continue
%         end
    end
    fr{i} = tmp;
    ac{i} = ta;
    if ~mod(i,10)
        fprintf('|')
    end
end
fprintf(']\n')

frp = cellfun(@median, fr);
mf = median(frp);
frp = frp/mf;
vp = frp.^-.5;
figure, hold on, cellfun(@(x,y)scatter(ones(1,length(y))*x, y.^-.5 * sqrt(mf), 'MarkerEdgeColor', [.7 .7 .7]), num2cell(th), fr)
hold on
plot(th, frp), hold on, plot(th, vp, 'LineWidth', 2)