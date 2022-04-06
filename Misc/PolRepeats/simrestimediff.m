function out = simrestimediff(tfseq)

%tfseq = classes of motion
if nargin < 1
    tfseq = zeros(1,68);
    tfseq(5:10) = 1;
    tfseq(17:23) = 1;
    tfseq(58:63) = 2;
    tfseq(34:39) = 0.5;
    tfseq(48:55) = 0.5;
end

x = 1:length(tfseq);

[xx, yy] = meshgrid(x, x);

zz = bsxfun(@(x,y) abs(x - y) <= 0.5, tfseq, tfseq');
zz = double(logical(zz));

figure, surface(xx,yy,zz, 'EdgeColor', 'none')
colormap([1 1 1; 0 0 0])