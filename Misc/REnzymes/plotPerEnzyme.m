function out= plotPerEnzyme(inresult)
len = 19282;
[names, ~, vals] = unique(inresult(:,1));
out = [];
figure('Name', 'Digest Plot', 'Position', [100 100 1720 880])
gca;
%For each enzyme
for i = 1:length(names)
    cla;
    xlim([0 len]);
    ylim([-1 1]);
    inds = vals == i;
    snip = inresult(inds, :);
    text(0,.9,sprintf('%s, REnzyme %d of %d, site %s%s, %s overhang',  names{i}, i, length(names), snip{1,2}, snip{1,5} ), 'Interpreter','none')
    text(0,.45,sprintf('%s\n', snip{:,6}))
    x = [snip{:,3}];
    %For each site
    for j = 1:size(snip,1)
        if strcmp(snip{j,4}, '5''')
            y = 1;
        else
            y = -1;
            x(j) = -x(j);
        end
        line([0 len], [0 0])
        xx = snip{j,3};
        line([xx xx], [0 y])
    end
    x = [1 sort(abs(x)) len];
    dx = diff(x);
    for j = 1:length(dx)
        text(mean(x(j:j+1)),0.2, sprintf('%0.2fkb', dx(j)/1e3 ))
    end
    
    switch questdlg('Keep Enzyme?', 'Keep?', 'Yes', 'No', 'No')
        case 'Yes'
            cmt = inputdlg();
            %Output is Name Site Frag2 Frag2 locs comment
            out = [out; names(i) snip(1,2) {dx(1)} {dx(end)} {x} cmt]; %#ok<AGROW>
    end
end
end