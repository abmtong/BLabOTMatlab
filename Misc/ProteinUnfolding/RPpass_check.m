function out = RPpass_check(inst)

%Plot checks: plot ext with mu values

opts.fil = 200;


len = length(inst);
for i = 1:len
    tmp = inst(i);
    figure Name RPpass_check
    hold on
    %Plot data
    plot(windowFilter(@mean, tmp.ext, opts.fil, 1))
    
    %Plot lines for U/F
    xl = [1 length(tmp.ext)];
    axis tight
    %Used ones = green, original guess = red
    plot(xl, tmp.extuf(1) *[1 1], 'g')
    plot(xl, tmp.extuf(2) *[1 1], 'g')
    plot(xl, tmp.extuf(3) *[1 1], 'r')
    plot(xl, tmp.extuf(4) *[1 1], 'r')
    yl = tmp.extuf(1:2) + [-1 1] * ( tmp.extuf(2) - tmp.extuf(1) ) * 0.3;
    
    %Plot lines for transitions
    hei = size(tmp.rips, 1);
    for j = 1:hei
        switch tmp.rips(j,end)
            case {1 2} %U>F and F>U, full line
                plot(tmp.rips(j,1) * [1 1], yl, 'k')
            case 3 %F>F, line on bottom only
                plot(tmp.rips(j,1) * [1 1], [yl(1) tmp.extuf(1)], 'k')
            case 0 %UU
                plot(tmp.rips(j,1) * [1 1], [yl(2) tmp.extuf(2)], 'k')
        end
    end
    
end