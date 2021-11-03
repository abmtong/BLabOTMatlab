function trimEndOfPhage()
%Allows you to trim the end of a phage trace (when you're trying to sever the tether) for prettiness reasons

[files, path] = uigetfile('C:\Data\*.mat','','','MultiSelect','on');

%Make the figure window large (10% border on each side)
scrsz = get(groot,'ScreenSize');
sz = [scrsz(3:4)*.1 scrsz(3:4)*.8];
fg = figure('Name','PhageTrim','Position', sz);
ax = gca;

if ~iscell(files)
    files = {files};
end

for i = 1:length(files)
    %loads stepdata struct.
    load([path files{i}])
    cla(ax)
    hold(ax, 'on')
    cellfun(@plot, stepdata.time, stepdata.extension)
    while true
        [x, ~] = ginput(1);
        mn = min(cellfun(@min, stepdata.extension));
        mx = max(cellfun(@max, stepdata.extension));
        ln = line([1 1]*x, [mn mx]);
        drawnow
        switch questdlg('Crop here?','Crop?','Yes','Retry','No, Skip', 'No, Skip');
            case 'Yes'
                %Find segment crop occurs in (first with nonempty inds{i})
                cellfind = @(ce) (find(ce > x,1));
                inds = cellfun(cellfind, stepdata.time, 'UniformOutput', false);
                for j = 1:length(inds)
                    if ~isempty(inds{j})
                        seg = j;
                        ind = inds{j};
                        break
                    end
                end
                if seg
                    fnames = fieldnames(stepdata);
                    for j = 1:length(fnames)
                        if iscell(stepdata.(fnames{j}))
                            temp = stepdata.(fnames{j});
                            temp = temp(1:seg);
                            temp{seg} = temp{seg}(1:ind);% I guess if this occurs at a bdy it will leave a 1 pt segment, but w/e, rare case
                            stepdata.(fnames{j}) = temp;
                        end
                    end
                    save([path files{i}], 'stepdata')
                end
                break
            case 'Retry'
                delete(ln)
                continue
            case 'No, Skip'
                break
        end
    end
end

close(fg)