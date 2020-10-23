function [out, munew] = linfitV3(mu)

%Maybe just ensemble fit by @ T's, and see how non-linear it may be
%... Hey, this is pretty linear. So maybe linear is ok.

nT = arrayfun(@(x) sum(num2cdn(x) == 2), 1:256);

y = zeros(1,5);

for i = 0:4
    y(i+1) = mean( mu( nT == i) );
end

figure, plot(0:4, y);

