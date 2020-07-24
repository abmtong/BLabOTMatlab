function PhageGUI_HMM()
%PhageGUI, but now programmatic - GUIDE has bad limitations/bugs

%Add paths
thispath = fileparts(mfilename('fullpath'));
addpath (thispath)                      %PhageGUICrop
addpath ([thispath '\Helpers\'])        %Filename sorter
addpath ([thispath '\StepFind_KV\'])    %windowFilter
addpath ([thispath '\StepFind_HMM\'])   %HMM

%Load settings file (or create one)
path = 'C:\Data';
file = 'pHMMMMDDYYN00S00P00.mat';
name = 'MMDDYYN00S00P00';
if exist('GUIsettingsHMM.mat', 'file')
    load('GUIsettingsHMM.mat', 'path');
else
    c = 'Settings file for PhageGUI_HMM'; %#ok<*NASGU> - A lot of uicontrols will be unused, too - OK
    save('GUIsettingsHMM.mat', 'c');
end

%Declare variables for static workspace - or just shove everything in a struct [less readable]
fcdata = [];
cropLines = cell(1,4);
stepLines = {[] []};
filtLine = [];
cropT = [];
conF = [];
timF = [];
forF = [];
fil = [];
dec = [];

stripes = gobjects(1);

%Construct figure
scrsz = get(0, 'ScreenSize');
%Default size is 3/4 of each dimension
fig = figure('Name', 'PhageGUI_HMM', 'Position', [scrsz(3:4)/8 .75*scrsz(3:4)], 'Visible', 'off');

panaxs = uipanel('Position', [.1 0 .9 .95]);
panaxs.BackgroundColor = [1 1 1]; %make it white
mainAxis = axes('Parent', panaxs, 'Position', [.05 .31 .94 .68]);
hold(mainAxis,'on')
subAxis  = axes('Parent', panaxs, 'Position', [.05 .05 .94 .2]);
hold(subAxis, 'on')
% linkaxes([mainAxis, subAxis], 'x')

%Top row of buttons
pantop = uipanel('Position', [0 .95 1 .05]);
loadFile = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [ 0, 0, .1, 1], 'String', 'Load File', 'Callback',@loadFile_callback);
loadCrop = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.1, 0, .1, 1], 'String', 'Load Crop', 'Callback',@loadCrop_callback);
permCrop = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.2, 0, .075, 1], 'String', 'Crop', 'Callback',@permCrop_callback);
permCropT= uicontrol('Parent', pantop, 'Style', 'text', 'Units', 'normalized', 'Position', [.275, .5, .025, .5], 'String', 'CropNum', 'Callback',[]);
permCropB= uicontrol('Parent', pantop, 'Style', 'edit', 'Units', 'normalized', 'Position', [.275, 0, .025, .5], 'String', '-1', 'Callback',@loadCrop_callback);
measLine = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.3, 0, .1, 1], 'String', 'Measure', 'Callback',@measLine_callback);
trimTrace= uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.4, 0, .1, 1], 'String', 'Trim', 'Callback',@trimTrace_callback);
toWorksp = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.5, 0, .05, 1], 'String', 'ToWkspace' , 'Callback',@toWorksp_callback);
locNoise = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.55, 0, .05, 1], 'String', 'LocNoise' , 'Callback',@locNoise_callback);
customB1 = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.60, 0.5, .05, .5], 'String', 'But01', 'Callback',@custom01_callback);
customB1t= uicontrol('Parent', pantop, 'Style', 'edit', 'Units', 'normalized', 'Position', [.60, 0, .05, .5], 'String', '[2.5, 0]', 'Callback', []);
customB2 = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.65, .5, .05, .5], 'String', 'But02', 'Callback',@custom02_callback);
customB3 = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.65, 0 , .05, .5], 'String', 'But03', 'Callback',@custom03_callback);
trcNotes = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.7, 0, .2, 1], 'Style', 'text', 'String', 'Comment');
fixLimit = uicontrol('Parent', pantop, 'Units', 'normalized', 'Position', [.9, 0, .1, 1], 'String', 'Print' , 'Callback',@printFig_callback);

%Left bar of text inputs
panlef = uipanel('Position',[0 0 .1 .95]);
panlef.BackgroundColor = [1 1 1]; %make it white
fileSlider= uicontrol('Parent', panlef, 'Style', 'slider', 'Units', 'normalized', 'Position', [0 .90 1 .1], 'Callback', @fileSlider_callback);
txtSlider = uicontrol('Parent', panlef, 'Style', 'text', 'Units', 'normalized', 'Position', [.15 .901 .7 .05], 'String', '1');
clrGraph  = uicontrol('Parent', panlef,                  'Units', 'normalized', 'Position', [0 .875 1 .025], 'String', 'Clear Graph', 'Callback', @clrGraph_callback);
filtFactT = uicontrol('Parent', panlef, 'Style', 'text', 'Units', 'normalized', 'Position', [0 .85 .5 .025], 'String', 'Filt Fact');
filtFact  = uicontrol('Parent', panlef, 'Style', 'edit', 'Units', 'normalized', 'Position', [0 .8 .5 .05], 'String', '10', 'Callback', @refilter_callback);
deciFactT = uicontrol('Parent', panlef, 'Style', 'text', 'Units', 'normalized', 'Position', [.5 .85 .5 .025], 'String', 'Dec Fact');
deciFact  = uicontrol('Parent', panlef, 'Style', 'edit', 'Units', 'normalized', 'Position', [.5 .8 .5 .05], 'String', '2', 'Callback', @refilter_callback);
plotCal   = uicontrol('Parent', panlef,                  'Units', 'normalized', 'Position', [0 .7 .5 .05], 'String', 'Plot Cal', 'Callback', @plotCal_callback);
plotOff   = uicontrol('Parent', panlef,                  'Units', 'normalized', 'Position', [.5 .7 .5 .05], 'String', 'Plot Off', 'Callback', @plotOff_callback);
plotRaw   = uicontrol('Parent', panlef,                  'Units', 'normalized', 'Position', [0 .65 .5 .05], 'String', 'Plot Raw', 'Callback', @plotRaw_callback);
%Load first file
loadFile_callback

fig.Visible = 'on';

%%%%Callbacks
    function loadFile_callback(~,~, f, p)
        if nargin < 4
            %Prompt the user to select a file
            [f, p] = uigetfile([path filesep 'pHMM*.mat'], 'MultiSelect','off','Pick a Phi29 HMM File');
            if ~p; %No file selected, do nothing
                return
            end
            file = f;
            path = p;
            save('GUIsettingsHMM.mat', 'path', '-append')
            %Format the slider
            d = dir([path filesep 'pHMM*.mat']);
            d = {d.name};
            len = length(d);
            %Sort, so it's by day then by N##
            d = sort_phage(d);
            fileSlider.Min = 1;
            fileSlider.Max = len;
            fileSlider.String = d;
            fileSlider.Enable = 'on';
            if len ==1
                fileSlider.Enable = 'off';
            else
                fileSlider.SliderStep = [1 10] ./ (len-1);
            end
        else
            file = f;
            path = p;
        end
        %Load the file
        load([path file],'fcdata');
        name = file(5:end-4);
        cla(mainAxis)
        fig.Name = sprintf('PhageGUI_HMM %s', name);
        
        %Load comment
        if isfield(fcdata.opts.opts,'comment')
            trcNotes.String = fcdata.opts.opts.comment;
        else
            trcNotes.String = '';
        end
        
        fileSlider.Value = find(cellfun(@(x) strcmp(x, file),fileSlider.String),1);
        txtSlider.String = sprintf('%s\n%d/%d', name, round(fileSlider.Value), fileSlider.Max);
        
        loadCrop.String = 'Load Crop';
        
        %Plot
        refilter_callback
        fixLimit_callback
        loadCrop_callback
%         locNoise_callback
    end

    function loadCrop_callback(~,~)
        %loadcrop is now load HMM iter.
        istr = permCropB.String;
        i = str2double(istr);
        if i < 1
            %check for hmmfinished
            ifin = fcdata.hmmfinished;
            if ifin > 0
                i = ifin;
            else %still processing, choose latest iter
                i = length(fcdata.hmm);
                if i == 0
                    return
                end
            end
        end
        
        imax = length(fcdata.hmm);
        if ~imax
            return
        end
        ind = min(imax, i);
        hmm = fcdata.hmm(ind);
        
        arrayfun(@delete,subAxis.Children)
        
        %Plot a on bottom
        %find zero first
        a = hmm.a;
        [~, azr] = max(a);
        ax = ((1:length(a)) - azr) * 0.1;
        a(azr) = 0;
        plot(subAxis, ax, a)
        %plot noise
        line(subAxis, hmm.sig * [1 1],  subAxis.YLim, 'LineStyle', '--');
        
        axis(subAxis, 'tight')
        
        [~, scl] = prepTrHMM(fcdata.con, 0.1);
        %plot HMM on top
        %MLE first, so it's below
        plot(mainAxis, fcdata.tim, scl(1)*(hmm.fitmle-scl(2)), 'Color', 'b', 'LineWidth', 1)
        %and then vitt.
        plot(mainAxis, fcdata.tim, scl(1) * (hmm.fit-scl(2)), 'Color', 'r', 'LineWidth', 1)
    end

    function fileSlider_callback(~,~)
        file = fileSlider.String{round(fileSlider.Value)};
        loadFile_callback([], [], file, path)
    end

    function refilter_callback(~,~)
        %Filter
        fil = str2num(filtFact.String); %#ok<ST2NM>
        dec = str2double(deciFact.String);
        if ~isempty(fil) || dec ~= 1
            conF = windowFilter(@mean, fcdata.con, fil, dec);
            timF = windowFilter(@mean, fcdata.tim, fil, dec);
            forF = windowFilter(@mean, fcdata.frc, fil, dec);
        else
            conF = fcdata.con;
            timF = fcdata.tim;
            forF = fcdata.frc;
        end
        
        %Plot contour on top
        arrayfun(@delete,mainAxis.Children)
        plot(mainAxis, fcdata.tim, fcdata.con, 'Color', .7 * [1 1 1]);
        filtLine = plot(mainAxis, timF, conF);
        axis(mainAxis, 'tight')
        
    end

    function toWorksp_callback(~,~)
        assignin('base','guiCf',conF);
        assignin('base','guiTf',timF);
        assignin('base','guifcdata',fcdata);
    end

    function clrGraph_callback(~,~)
        %Delete all lines, text objects
        len = length(mainAxis.Children);
        %Is it faster to grab all of mainAxis.Children and index the reference?~~~~~~~~~~~~~
        toDel = false(1,len);
        for i = 1:len
            gobj = mainAxis.Children(i);
            if isgraphics(gobj, 'Text')
                toDel(i)=true;
            elseif isgraphics(gobj, 'Line') && length(gobj.XData) == 2;
                toDel(i)=true;
            end
        end
        arrayfun(@delete, mainAxis.Children(toDel))
    end

    function measLine_callback(~,~)
        [x, y] = ginput(2);
        dx = abs(diff(x));
        dy = abs(diff(y));
        
        line(x,y)
        text(x(end),y(end),sprintf('(dx,dy,m) = (%0.2f, %0.2f, %0.2f)\n',dx,dy,dy/dx), 'Clipping', 'on')
    end

    function permCrop_callback(~,~)
        cropstr = permCropB.String;
        if strcmp(cropstr,'1')
            cropstr = '';
        end
        [x, ~] = ginput(2);
        cropfp = sprintf('%s\\CropFiles%s\\%s.crop', path, cropstr, name);
        cropp = fileparts(cropfp);
        if ~exist(cropp, 'dir')
            mkdir(cropp)
        end
        if ~issorted(x)
            if exist(cropfp, 'file')
                fprintf('Deleted crop%s for %s\n', cropstr, name)
                delete(cropfp)
            end
            return
        end
        fid = fopen(cropfp, 'w');
        fwrite(fid, sprintf('%f\n%f', x));
        fclose(fid);
        loadCrop_callback
    end

    function trimTrace_callback(~,~)
        [x,~] = ginput(2);
        x = sort(x);
        
        ln1 = line([1 1]*x(1), [0 1e4]);
        ln2 = line([1 1]*x(2), [0 1e4]);
        drawnow
        switch questdlg('Trim here?','Trim?','Yes','No', 'No');
            case 'Yes'
                %Find index of first greater than start, last less than end
                cellfind = @(ce) (find(ce > x(1),1));
                cellfind2 = @(ce) (find(ce < x(2),1, 'last'));
                inds = cellfun(cellfind, fcdata.tim, 'UniformOutput', false); 
                inds2 = cellfun(cellfind2, fcdata.tim, 'UniformOutput', false);
                %Act on every field that is a cell
                fnames = fieldnames(fcdata);
                %Probably better to reverse j and k loops, but negligible performance difference
                for j = 1:length(fnames)
                    if iscell(fcdata.(fnames{j}))
                        temp = fcdata.(fnames{j});
                        for k = length(inds):-1:1 %process in reverse so cell removal, e.g. a(3) = [], doesn't disrupt indicies
                            %Check that there exists a min and a max - i.e. is within inds
                            st = inds{k};
                            en = inds2{k};
                            if ~isempty(st) && ~isempty(en)
                                temp2 = temp{k};
                                ln = length(temp2);
                                %Check for entire removal
                                if st ==1 && en == ln
                                    temp(k) = [];
                                    continue
                                    %Check for middle removal (both indicies not at bdy - then need to segment in two)
                                elseif st ~= 1 && en ~= ln
                                    left = temp2(1:st);
                                    right = temp2(en:end);
                                    temp = [temp(1:k-1) {left right} temp(k+1:end)];
                                    %Half removal
                                else
                                    temp2(st:en) = [];
                                    temp{k} = temp2;
                                end
                            end
                        end
                        fcdata.(fnames{j}) = temp;
                    end
                end
                %Remove cut bits that no longer are necessary
                if isfield(fcdata, 'cut')
                    fnames = fieldnames(fcdata.cut);
                    keepind = ~cellfun(@(x) any(x<fcdata.tim{1}(1) | x>fcdata.tim{end}(end)), fcdata.cut.time);
                    for j = 1:length(fnames)
                        fcdata.cut.(fnames{j}) = fcdata.cut.(fnames{j})(keepind);
                    end
                end
                
                switch questdlg('Edit comment?','Comment?','Yes','No', 'No');
                    case 'Yes'
                        resp = inputdlg('Comment', 'Enter new comment', [1,80], {trcNotes.String});
                        if ~isempty(resp)
                            trcNotes.String = resp{1};
                            fcdata.comment = trcNotes.String;
                        end
                end
                save([path file], 'stepdata')
                loadFile_callback([], [], file, path)
            case 'No'
                delete(ln1)
                delete(ln2)
        end
    end

    function fixLimit_callback(~,~)
%         tlim = [fcdata.tim(1) fcdata.tim(end)];
% %         clim = [min(cellfun(@min, fcdata.con)), max(cellfun(@max, fcdata.con))];
% %         flim = [min(cellfun(@min, fcdata.frc)), max(cellfun(@max, fcdata.frc))];
% %         clim = [2500 5000];
%         clim = [min(fcdata.con)), max(cellfun(@grabmax, fcdata.con, fcdata.frc))];
%         if length(clim) ~= 2
%             clim = [0 6000];
%         end
        zoom(mainAxis, 'reset')
        zoom(subAxis, 'reset')
        
        axis(mainAxis, 'tight')
        axis(subAxis, 'tight')
%         xlim(mainAxis, tlim)
%         try
%             ylim(mainAxis, clim)
%         catch
%             ylim(mainAxis, [0 1e4])
%         end
%         ylim(subAxis, flim)

    end

    function m = grabmin(c, f)
        m = double(min(c(f>5)));
        if isempty(m)
            m = 1e4;
        end
    end

    function m = grabmax(c, f)
        m = double(max(c(f>5)));
        if isempty(m)
            m = 0;
        end
    end

    function locNoise_callback(~,~)
        %Plot the local noise levels every so-and-so points
        netlen = length(fcdata.tim);
        if netlen > 1e5
            noiwin = 1e3;
        else
            noiwin = 500;
        end
        szs = cellfun(@length, fcdata.tim);
        szs = floor(szs/noiwin);
        for i = 1:length(fcdata.tim)
%             cfil = fcdata.con{i} - smooth(fcdata.con{i},125)';
            for j = 1:szs(i)
                %Estimate noise, annotate with text
                ran = (j-1)*noiwin+1:j*noiwin;
                textt = double(mean(fcdata.tim{i}(ran([1 end]))));
                textc = double(mean(fcdata.con{i}(ran)));
%                 textv = std(cfil(ran));
                textv = sqrt(estimateNoise(fcdata.con{i}(ran), [], 2));
                if j == 1
                    pfit = @(x)polyfit(1:length(x), x, 1);
                    textvel = pfit(fcdata.con{i});
                    textvel = -textvel(1) * 2500;
                    text(mainAxis, textt, textc+20, sprintf('%0.2f, %0.1fv',textv, textvel), 'Rotation', 90, 'Clipping', 'on')
                else
                    text(mainAxis, textt, textc+20, sprintf('%0.2f',textv), 'Rotation', 90, 'Clipping', 'on')
                end
            end
        end
    end

    function plotCal_callback(~,~)
        if isfield(fcdata.opts, 'cal')
            plotcal(fcdata.opts.cal);
        end
    end

    function plotOff_callback(~,~)
%         if isfield(fcdata, 'off')
%             plotoff(fcdata.off);
%         end
    end

    function plotRaw_callback(~,~)
%         plotraw(fcdata)
%         xlim(mainAxis.XLim)
    end

    function custom01_callback(~,~)
        %{
        customB1.String = 'ConSec';
        a = ginput(2);
        a = sort(a(1:2));
        %find feedback cycle
        tstart = a(1);
        tend = a(2);
        inds = cellfun(@(x) ~isempty(find(x>tstart,1)) , fcdata.tim);
        fcyc = find(inds,1);
        guiConSec = fcdata.con{fcyc}( fcdata.tim{fcyc} > tstart & fcdata.tim{fcyc} < tend );
        assignin('base', 'guiConSec', guiConSec);
        %}



        customB1.String = 'AspectRatio';
        xl = mainAxis.XLim;
        yl = mainAxis.YLim;
        %Aspect ratio is 80px = 5bp, 50px = 200ms -> 1bp for 64ms on a square axis
        %Keep 
        yr = diff(yl);
        
        %get axes size from sizes of containing panels
        fgps = fig.Position(3:4);
        pnsz = panaxs.Position(3:4);
        axsz = mainAxis.Position(3:4);
        axdim = fgps.*pnsz.*axsz;
        %Moffit: 1bp for 0.064s; Group Meeting: 15bp per .200s = .013
        xr = yr * .03 * axdim(1)/axdim(2);
        mainAxis.XLim = xl(1) + [0 xr];
        cellfun(@(x)set(x,'LineWidth',1.5), {filtLine})
        
        
        xl = mainAxis.XLim;
        yl = mainAxis.YLim;
        args = str2num(customB1t.String); %#ok<ST2NM>
        ssz = args(1);
        soff = args(2);
        liney = soff:ssz:1e4;
        lineycrop = liney(liney > yl(1) & liney < yl(2));
        
        %make 2.5 2.5 2.5 1.1 steps
        if length(args) > 2
            ssz = -args(3);
            lineycrop = [lineycrop' lineycrop'+ssz lineycrop'+2*ssz lineycrop'+3*ssz];
            lineycrop = lineycrop(:)';
        end
        
        delete(stripes);
        stripes = gobjects(1, length(lineycrop));
        for i = 1:length(lineycrop)
            stripes(i) = line(mainAxis,xl, lineycrop(i) * [1 1], 'LineStyle', ':', 'Color', [1 1 1]*0);
        end
        
        stripes(end+1) = line(subAxis, ssz * [1 1],  subAxis.YLim);
        
    end

    function custom02_callback(~,~)
        addpath([thispath '\PairwiseDist']); %PWD code
        customB2.String = 'Take PWD';
        %plot PWD in separate window
        a = ginput(2);
        a = a(1:2);
        a = sort(a);
        cropfcn = @(x, y, z) x(y>z(1) & y<z(2) ); %cropfcn(con, tim, a) = con(tim>a(1) & tim<a(2))
        concrop = cellfun(@(x,y)cropfcn(x,y,a), {fcdata.con}, {fcdata.tim}, 'uni', 0);
%         concrop = [concrop{:}];
        concrop = concrop(~cellfun(@isempty, concrop));
        
        fils  = [3 5 10 25];
        binsz = .1;
        pfils = [1 5 10] * .1/binsz;
        pfils = round(pfils);
        
        %plot PWD in separate window
        fg = figure('Name', 'PGUI PWDs');
        len = length(fils);
        hei = length(pfils);
        for i = 1:len
            for j = 1:hei
                sumPWDV1b(concrop, fils(i), binsz, pfils(j));
                tempfig = gcf;
                tempax = gca;
                newax = copyobj(gca, fg);
                newax.Position = [(i-1)/len (j-1)/hei 1/len 1/hei];
                text(newax, newax.XLim(1), mean(newax.YLim), sprintf('[%d, %0.2f, %d]', fils(i), binsz, pfils(j)));
                xlim(newax, [0 30]);
                delete(tempfig);
            end
        end
        
        %assignin
        [pwd, pwdx] =  sumPWDV1b(concrop,10,0.1,5); close(gcf);
        ain.x = pwdx;
        ain.y = pwd;
        ain.con = concrop;
        ain.name = name;
        ain.time = a;
        assignin('base', 'guiPWD', ain)
    end

    function custom03_callback(~,~)
        
        %{
        customB3.String = 'GetBacktracks';
        a = ginput(4); %select left, start bt, end bt, right
        %get relevant numbers
        %extract left to right
        cropt = a([1 4]);
        %extract backtrack stats
        btt = a([2 3]);
        btc = a([2 3], 2);
        
        %extract from guistepdata
        cropfcn = @(x, y, z) x(y>z(1) & y<z(2) ); %cropfcn(con, tim, a) = con(tim>a(1) & tim<a(2))
        concrop = cellfun(@(x,y)cropfcn(x,y,cropt), fcdata.con, fcdata.tim, 'uni', 0);
        frccrop = cellfun(@(x,y)cropfcn(x,y,cropt), fcdata.frc, fcdata.tim, 'uni', 0);
        timcrop = cellfun(@(x,y)cropfcn(x,y,cropt), fcdata.tim, fcdata.tim, 'uni', 0);
        keepind = ~cellfun(@isempty, concrop);
        
        stepback.con = concrop(keepind);
        stepback.tim = timcrop(keepind);
        stepback.frc = frccrop(keepind);
        stepback.t = cropt;
        stepback.sb = [btt(:) btc(:)];
        %save
        sbpath = sprintf('%s\\Backtracks\\', path);
        if ~isdir(sbpath)
            mkdir(sbpath)
        end
        save(sprintf('%s\\Backtracks\\phBT%sS%0.2f.mat', path, name, btt(1)), 'stepback')
        
        pan on
        %}
        

        customB3.String = 'ScaleFCs';
        str = permCropB.String;
        if strcmp(str, '1')
            str = '';
        end
        tmp = FCrescale([path file], str);
        if ~isempty(tmp)
            fcdata = tmp;
            refilter_callback
        end
        %{
        
        customB3.String = 'Recalc Contour';
        %XWLC fcn
        function outXpL = XWLC(F, P, S, kT)
            %Simplification var.s
            C1 = F*P/kT;
            C2 = exp(nthroot(900./C1,4));
            outXpL = 4/3 ...
                + -4./(3.*sqrt(C1+1)) ...
                + -10*C2 ./sqrt(C1) ./(C2-1).^2 ...
                + C1.^1.62 ./ (3.55+ 3.8* C1.^2.2) ...
                + F./S;
        end
        
        %}
        
        %Recalc XWLC
        %DNA: PL=50, SM=700,nm/bp = 0.34
        %GheD: 30, 1200
        %RNA: 60 , 400, 0.27
        %One on new: 43, 845
        %Hyb?
        %'XWLC PL(nm), 50D 40R 35H' 'XWLC SM(pN), 700D 450R 500H' 'kT (pN nm)' 'Rise/bp (nm/bp)'...
        %Psor30: 50 500; 4% incr.
        %Psor100: 45 370; 8% incr.
%         pl = 40;
%         sm = 700;
%         npb = 0.34;
%         fcdata.con = cellfun(@(x,y) x ./ XWLC(y, pl, sm, 4.14)./ npb, stepdata.extension, fcdata.frc, 'uni', 0);
%         stepdata.cut.contour = cellfun(@(x,y) x ./ XWLC(y, pl, sm, 4.14)./ npb, stepdata.cut.extension, stepdata.cut.force, 'uni', 0);
%         refilter_callback
    end

    function printFig_callback(~,~)
        print(fig, sprintf('.\\PhagePrtSc%s', datestr(now, 'yymmddHHMMSS')),'-dpng',sprintf('-r%d',96))
    end

%%%%Helpers
    function varargout = plotCell(ax, x, y)
        out = cell(1,length(x));
        for i = 1:length(x)
            out{i} = plot(ax, x{i}, y{i}, 'Color', getColor(i));
        end
        if nargout
            varargout{1} = out;
        end
    end

    function outColor = getColor(i)
        col0 = 2/3; %blue
        dcol = .1; %10 color cycle, enough to tell apart & slider fast-move is 10 segments
        h = mod(col0 + (i-1)*dcol,1); %Color wheel
        s = 1; %1 for bold colors, .25 for pastel-y colors
        v = .6; % too high makes yellow difficult to see, too low and everything is muddy
        outColor = hsv2rgb( h, s, v);
    end
end