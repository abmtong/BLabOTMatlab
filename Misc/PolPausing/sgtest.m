function sgtest(indata, insgparams)

%indata is your data
%sgparams is your sgf filter [rank, width]

y = abs(fft(indata));
x = (1:length(y))/length(y);

y = y/y(2);

sg = sgolay(insgparams(1), insgparams(2));
sgf = sg( (end+1)/2, :);

yy = abs(fft( [sgf zeros(1,1e5)] ));
xx = (1:length(yy))/length(yy);

yy =yy/yy(1);

figure, ax = gca; plot(x,y); hold on, plot(xx,yy);
ax.YScale = 'log';
