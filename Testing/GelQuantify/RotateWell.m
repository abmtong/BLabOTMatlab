function [ ang, img ] = RotateWell( inimg )

%inimg is a bnw image of one lane of a gel, find angle to make the peak maximum the flattest

wid = size(inimg, 2);

maxx = zeros(1,wid);

%find darkest spot
for i = 1:wid
    [~,maxx(i)] = min(smooth(double(inimg(:,i)),5));
end

%reject outliers
med = median(maxx);
mad = median(abs(med-maxx));
madscal = mad * 2 * 1.68;
keepind = maxx > med - madscal & med + madscal > maxx;

xs = 1:wid;

xs = xs(keepind);
maxx = maxx(keepind);

pf = polyfit(xs, maxx, 1);
sl = pf(1);
ang = atan(sl);

img = imrotate(inimg, ang/pi*180, 'bilinear');
figure, plot(maxx), hold on, plot((1:wid)*pf(1)+pf(2));
figure, imshow(inimg);
figure, imshow(img);

sumy = sum(img, 2);
figure, plot(sumy);
findpeaks(-sumy)

