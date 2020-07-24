function out = pwdd(iny, dy, dn)

if nargin < 3
    dn = 50;
end
if nargin < 2
    dy = 2;
end

%Make 2d histogram by time
%X probably use a kdf-style method (add gaussian at pt.)

xe = 0:dn:length(iny)+dn;
ye = ( floor(min(iny)/dy): ceil(max(iny)/dy) ) * dy;

hh = histcounts2(1:length(iny), iny, xe, ye);

%perform 2D acorr
xl = length(xe)-1;
yl = length(ye)-1;

ac = zeros(xl+1, yl+1);
%for every dx and dy....
for i = 0:xl
    for j = 0:yl
        %use cauchy-schwarz--ish method
        a = hh(1:end-i, 1:end-j);
        b = hh(1+i:end, 1+j:end);
        ac(i+1,j+1) = sum(sum(a.*b))/ sqrt( sum(a(:).^2)*sum(b(:).^2) );
    end
end
% out = ac;
figure, surf(ac);
figure, surf(hh);
