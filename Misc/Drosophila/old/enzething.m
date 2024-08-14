function out = enzething(instcc, nams)

%input is cell of ezSum per sample
% second layer cell is nc, assume last = 14

len = length(instcc);

for i = 1:len
    tmp = instcc{i};
    hei = length(tmp);
    for j = 1:hei
        dat = tmp{j};
        ezSum_plotunnorm(dat)
        fg = gcf;
        fg.Name = sprintf('Movie %s, nc%d, %s', nams{i}, j + 14 - hei, fg.Name);
    end
end