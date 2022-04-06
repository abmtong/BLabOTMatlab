function [out, mtr2] = fitrestimediff(inmtr)

len = length(inmtr);

inmtr0 = 1-inmtr;

%Random start guess
xg = rand(1,len);
%Bounds
% lb = zeros(1,len);
% ub = ones(1,len);
lb = -inf(1,len);
ub = inf(1,len);

lsqopts = optimoptions('lsqnonlin', 'OptimalityTolerance', 1e-12, 'StepTolerance', 1e-12);

ftfun = @(x0) bsxfun(@(x,y) abs( x - y ), x0, x0');
out = lsqnonlin( @(x0) ftfun(x0) - inmtr0 , xg, lb, ub, lsqopts);

%Normalze: Make minimum zero
out = out - min(out);

%Plot ft and inmtr
x = 1:len;
[xx, yy] = meshgrid(x, x);

figure('Name', 'fit'), surface(xx, yy, ftfun(out), 'EdgeColor', 'none'), set(gca, 'CLim', [0 1])
figure('Name', 'input'), surface(xx, yy, inmtr0, 'EdgeColor', 'none'), set(gca, 'CLim', [0 1])

% %Method 2:
% %Dot rows into each other
% mtr2 = zeros(len);
% %Normalize rows
% nmtr = bsxfun( @rdivide, inmtr, sqrt(sum(inmtr.^2, 2)) );
% for i = 1:len
%     mtr2(i,:) = sum( bsxfun( @times, nmtr(i,:), nmtr ), 2 )';
%     
% end
% 
% figure ('Name', 'byrows'), surface(xx,yy,1-mtr2, 'EdgeColor' , 'none'), set(gca, 'CLim', [0 1])

