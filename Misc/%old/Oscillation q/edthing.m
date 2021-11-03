function edthing(inx,iny, binsz)
tic
if nargin < 1
    inx = randn(1,1e7); %100kHz * 100s = 1e7 pts
    iny = randn(1,1e7); %100kHz * 100s = 1e7 pts
end
if nargin < 3
%     binsz = 0.5e-1;
    binsz = range(inx)/50;
end

%shift indata to natural coords
inx = floor(inx / binsz);
iny = floor(iny / binsz);

xoff = min(inx);
yoff = min(iny);

inx = inx - xoff + 1;
iny = iny - yoff + 1;

xr = max(inx);
yr = max(iny);

len = length(inx);
dirs = complex(zeros(1,len-1));
outc = zeros(xr,yr);
outd = complex(zeros(xr,yr));

for i = 1:len-1
    %shallow slope = l/r, steep = u/d
    isud = abs ( ( iny(i+1) - iny(i) ) / (inx(i+1) - inx(i)) ) > 1;
    if isud
        %check if up or down
        if iny(i+1) > iny(i) %up
            dirs(i) = 1i;
        else
            dirs(i) = -1i;
        end
    else
        % check if left or right
        if inx(i+1) > inx(i) %right
            dirs(i) = 1+0i;
        else %left
            dirs(i) = -1+0i;
        end
    end
    outc(inx(i), iny(i)) = outc(inx(i), iny(i)) + 1;
    outd(inx(i), iny(i)) = outd(inx(i), iny(i)) + dirs(i);
    if mod(i,1e6) == 0
        fprintf('|');
    end
end


[xx, yy] = meshgrid(1:xr, 1:yr);
xx = (xx'+xoff-1)*binsz;
yy = (yy'+yoff-1)*binsz;

%should probably normalize d by n, e.g. d = d ./ n

%norm d so largest arrow is length 1
outd = outd / max(abs(outd(:)));

figure, surface(xx, yy, zeros(size(xx)), outc, 'EdgeColor', 'none');
hold on, quiver(xx+binsz/2,yy+binsz/2, real(outd), imag(outd));
axis square
toc