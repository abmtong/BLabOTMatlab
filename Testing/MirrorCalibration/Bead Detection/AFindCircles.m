function circparams = AFindCircles(im)
rad = [6 15];
resize = 2; %Ghe: 1
wiener= [4 4]; %Ghe: [4,4]
relsz = 30; %Ghe: 6
thresh = 0; %Ghe: 0.3, 0 to use graythresh

circleFindDraw(im, rad);

imResize = imresize(im, resize);
circleFindDraw(imResize, rad);

imFilt = wiener2(imResize, wiener);
circleFindDraw(imFilt, rad);

imAdj = imadjust(imFilt);
circleFindDraw(imAdj, rad);

Bkgr = imopen(imAdj,strel('disk',relsz));
circleFindDraw(Bkgr, rad);

imBkgr = imAdj - Bkgr;
circleFindDraw(imBkgr, rad);

if thresh == 0
    thresh = graythresh(imBkgr);
end

imBW = im2bw(imBkgr, thresh );
circleFindDraw(imBW, rad);

% [cen, ra] = imfindcircles(imBW, [11 30]);
% 
% if(isequal(cen,[]))
%     disp ('No circles found');
%     return;
% end
% 
% yc = cen(:,1);
% xc = cen(:,2);
%     
% figure('Name','BnW');
% imshow(imBW);
% hold on;
% 
% for i = 1:length(xc);
%     rectpos = [yc(i) - ra(i),xc(i) - ra(i), 2*ra(i), 2*ra(i)];
%     rectangle('Position', rectpos,'Curvature', [1 1]);
%     line([yc(i) - ra(i),yc(i) + ra(i)], [xc(i),xc(i)]);
%     line([yc(i),yc(i)],[xc(i) - ra(i),xc(i) + ra(i)]);
%     %Label them with the array index
%     text(yc(i), xc(i),num2str(i));
% end

%circparams = [xc yc ra];

end