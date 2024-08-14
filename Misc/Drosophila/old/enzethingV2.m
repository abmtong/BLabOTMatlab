function out = enzethingV2(instcc, nams, nc)

%input is cell of ezSum per sample
% second layer cell is nc, assume last = 14

len = length(instcc);

for i = 1:len
    dat = instcc{i};
    
        ezSum_plotunnorm(dat)
        fg = gcf;
        fg.Name = sprintf('Movie %s, nc%d, %s', nams{i}, nc, fg.Name);
end