function circleFindDraw(image, radii)

warning('off','all')
name = inputname(1);
tic
[cen, ra] = imfindcircles(image, radii,'ObjectPolarity','dark');
t = toc;

figure('Name',name);
imshow(image);
hold on;

if(isequal(cen,[]))
    fprintf (['No circles found in ' name ', this took ' num2str(t) ' seconds.\n']);
    return;
else
    disp([num2str(length(ra)) ' circles found in ' name ', this took ' num2str(t) ' seconds.']);
end

yc = cen(:,1);
xc = cen(:,2);

for i = 1:length(xc);
    rectpos = [yc(i) - ra(i),xc(i) - ra(i), 2*ra(i), 2*ra(i)];
    rectangle('Position', rectpos,'Curvature', [1 1]);
    line([yc(i) - ra(i),yc(i) + ra(i)], [xc(i),xc(i)]);
    line([yc(i),yc(i)],[xc(i) - ra(i),xc(i) + ra(i)]);
    %Label them with the array index
    text(yc(i), xc(i),num2str(i));
end

warning('on', 'all')