function simulatedemipot(starthp)
if nargin < 1
    starthp = 1;
end
digs = zeros(1,100); %end digit


for i = 1:1e5
    dig1 = ceil(mod((100+starthp)/2,100));
    dig2 = ceil(mod(starthp/2,100));
    if dig1 == 0
        digs(100) = digs(100)+1;
    else
        digs(dig1) = digs(dig1)+1;
    end
    if dig2 == 0;
        digs(100) = digs(100)+1;
    else
        digs(dig2) = digs(dig2)+1;
    end
    starthp = dig1;
%     starthp = dig2;
end


figure, plot(digs)

fprintf('%d, ', find(digs > 0))
fprintf('\n')
fprintf('%d, ', find(digs > 1))
fprintf('\n')

