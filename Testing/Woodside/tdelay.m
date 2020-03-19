function tdelay(inx, tfdiff)
%given pt X, plot where it is after N pts
%Theory from M.Woodside's stuff

%declare time delays
t = 10+(0:100:1e3);
len = length(t);
figure('Name', sprintf('tdelay %d-%d pts', t([1 end]))), hold on

%plot over each other, but differentiate by color
%I like 
cmap = jet(len);
for i = 1:len
    xs = inx(1:end-t(i));
    ys = inx(1+t(i):end);
    if tfdiff
        ys = ys-xs;
    end
    scatter(xs, ys, 2, cmap(i,:))
end

%even though these pts aren't actually colored by colormap,
% show it to give the user a sense of what color means what
% Alternatively, change to scatter3(x, y, z==1, c==t)
% and look down z (CameraNorm = [0 1 0], CameraPosition = [0 0 1])
colormap jet
colorbar
set(gca, 'clim', [t(1) t(end)])