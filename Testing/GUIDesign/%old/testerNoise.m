nmax = 500;
ndif = 1;

noises = zeros(1,nmax/ndif);

for i = ndif:ndif:nmax
    fil = windowFilter(@median, guiC, i);
    noises(i/ndif) = C_var(guiC - fil);
end
[~, ind] = min(diff(noises));
figure; plot(noises); hold on; plot(diff(noises));
line([1 nmax],noises(ind) * [1 1]);

[~, ind2] = min(diff(windowFilter(@mean,noises,2)));
line([1 nmax],noises(ind2) * [1 1],'Color','r');
