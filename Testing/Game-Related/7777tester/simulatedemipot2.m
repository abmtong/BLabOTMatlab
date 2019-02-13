function simulatedemipot2(starthp, iters)
if nargin < 1
    starthp = 1;
end
if nargin < 2
    iters = 20; % will do 2^(n+1)-1 cases
end
digs = zeros(1,100); %end digit

function outdigs = demime(hp, iters)
    dg1 = ceil(mod((100+hp)/2,100));
    dg2 = ceil(mod(hp/2,100));
    
    if iters <= 1
        outdigs = [dg1 dg2];
    else
        outdigs = [demime(dg1, iters-1) demime(dg2, iters-1)];
    end
end

out = demime(starthp, iters);

%count digits in outdigs
for i = 1:100
    if i == 100
        digs(i) = sum(out == 0);
    else
        digs(i) = sum(out == i);
    end
end

figure, plot(digs)

fprintf('%d, ', find(digs > 0))
fprintf('\n')
fprintf('%d, ', find(digs > 1))
fprintf('\n')
end

