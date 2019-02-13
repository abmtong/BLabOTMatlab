tic
for i = 1:100
    filt = sgolayfilt(guiCd, 0, 25);
end
toc

tic
for i = 1:100
    filt = windowFilter(@mean, guiCd, 12);
end
toc

tic
for i = 1:100
    filt = medfilt1(guiCd, 25);
end
toc

tic
for i = 1:100
    filt = windowFilter(@median, guiCd, 12);
end
toc