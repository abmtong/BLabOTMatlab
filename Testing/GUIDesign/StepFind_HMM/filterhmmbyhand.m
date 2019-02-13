function [outstruct, outinds, outstructspecial] = filterhmmbyhand(inpf, nitermax)
if nargin < 2
    nitermax = inf;
end

if nargin < 1 || isempty(inpf)
    % [files, path] = uigetfile('C:\Data\pHMM*.mat','MultiSelect','on');
    [files, path] = uigetfile('C:\Users\Alexander Tong\Box Sync\Year 2 Semester 2\Res\MATLAB\Testing\GUIDesign\StepFind_HMM\pHMM*.mat','MultiSelect','on');
    %Check to make sure files were selected
    if ~path
        return
    end
    if ~iscell(files)
        files = {files};
    end
    
    len = length(files);
    instruct = cell(1,len);
    %build "struct array" (cell array, can probably be a struct array but do cell for now)
    for i = 1:len
        dt = load([path files{i}]);
        dt = dt.fcdata;
        instruct{i} = dt;
    end
    instruct = [instruct{:}];
else
    instruct = inpf;
    files = repmat({'noname'}, 1, length(instruct));
end

fg = figure;
%generate axes array
nd = 4;
axs = gobjects(nd);
for i = 1:nd^2
	axs(i) = subplot(nd, nd, i);
end
axs = axs';
isemptyaxs = ones(nd);
arrayfun(@(x)hold(x,'on'),axs)
axns = zeros(nd);
ended = 0;

len = length(instruct);
outinds = -ones(1, len);
curplot = 1;
while ~ended
    %plot things
    for i = 1:nd^2
        if isemptyaxs(i)
            %check if there's more to plot
            if curplot <= len
                con = instruct(curplot).con;
                axs(i).Title.String = sprintf('%s %0.1fs %0.1fkb', files{curplot}, instruct(curplot).tim(1), con(1)/1e3);
                [~, scl] = prepTrHMM(con,.1); %get shift so fit plots correctly
                conf = windowFilter(@mean, con, 5, 1);
                maxcon = max(con);
                mincon = min(con);
                tim = linspace(0, 15, length(con));
                timf = windowFilter(@mean, tim, 5, 1);
                %title
                axs(i).Title.String = sprintf('%s %0.1fs %0.1fkb', files{curplot}, instruct(curplot).tim(1), con(1)/1e3);
                %plot contour, filtered, pwd, fit
                plot(axs(i), tim, con, 'Color', [.7 .7 .7])
                plot(axs(i), timf, conf)
                %scale pwd so looks good on both axes
                hmmslice = instruct(curplot).hmm;

                niter = length(instruct(curplot).hmm);
                nuse = min(niter, nitermax);
                if nuse <= 0
                    pwdy = 1:251;
                    fit = 1:length(tim);
                else
                    pwdy = hmmslice(nuse).a;
                    fit = hmmslice(nuse).fit;
                end
                plot(axs(i), tim, (fit-scl(2)) / scl(1), 'k', 'LineWidth', 1)
                minpwd = min(pwdy(2:150));
                maxpwd = max(pwdy(2:150));
                pwdy = (maxcon-mincon) * (pwdy - minpwd) / (maxpwd-minpwd) + mincon;
                plot(axs(i), (1:length(pwdy)-1)*.1, pwdy(2:end))
                axs(i).XLim = [0 15];
                axs(i).YLim = [mincon maxcon];
                axns(i) = curplot;
                curplot = curplot + 1;
            end
            isemptyaxs(i) = 0;
        end
    end
    %check for end- all graphs empty / graph closed {useless check, code errors on waitforbuttonpress anyway}
    if all(~axns(:)) || ~isvalid(fg)
        break
    end
    
    %wait for click
    figure(fg) %make fg current
    prs = waitforbuttonpress;
    if prs == 0 %mouseclick
        curpt = fg.CurrentPoint; %in pixels
        lmb = fg.SelectionType; %lmb or rmb, see >doc Figure Properties
        %check whether overlaps an axis
        %get figure dims
        dms = fg.Position;
        ptx = curpt(1)/dms(3);
        pty = curpt(2)/dms(4);
        for i = 1:nd^2
            axp = axs(i).Position;
            tfx = axp(1) < ptx && ptx < (axp(1) + axp(3));
            tfy = axp(2) < pty && pty < (axp(2) + axp(4));
            if tfx && tfy && axns(i) %if in axis border and plot is nonempty
                %clear axis, fetch number, assign to outinds
                cla(axs(i))
                switch lmb
                    case 'normal'
                        res = 1;
                    case 'extend'
                        res = 2;
                    otherwise
                        res = 0;
                end
                outinds(axns(i)) = res; %1 for mouse1 ("accept"), 0 for mouse2 ("reject"), 2 for mouse3 ("special accept")
                axns(i) = 0;
                isemptyaxs(i) = 1;
            end
        end
    end
    pause(.1)%"real-time' loopiness
end
delete(fg)

outstruct = instruct(logical(outinds));
outstructspecial = instruct(outinds == 2);