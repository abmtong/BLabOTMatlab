function out = easyAnalyzeOpts(inOpts)
%Create a popup to choose what analysis method + options to use
%Returns an options struct that is passed to @easyAnalyze

%Make the figure
pxx = 600;
txty = 20;
nrows = 11; %Update this to how many rows used below
pxy = txty*nrows;
boxsz = [pxx,pxy];
%Use this fcn so we can count rows from the top instead of from the bottom
rx = @(x) pxy - x * txty;
%Get screensize so we can center this figure in the screen
ssz = get(0, 'ScreenSize');
ssz = ssz(3:4);
%Need ssz >= boxsz
ssz = max(boxsz, ssz);
fg = figure('Name', 'AProcessData Options', 'Position', [(ssz-boxsz)/2 boxsz]);
col = [0 100 300 400]; %Column positions, we're gonna do [Text Box   Text Box]

%Add stuff to the figure

%Row 1: Dropdown menus to choose presets
optMethod = {'Pairwise' 'Stepfinding: K-V' 'Stepfinding: KDF' 'Stepfinding: HMM' 'N-state HMM' 'Velocity distribution'};
dropMethL= uicontrol(fg, 'Style', 'text'     , 'Position', [col(1) rx(1) 100 txty], 'String', 'Analysis: ', 'HorizontalAlignment', 'right', 'FontSize', 12); %#ok<*NASGU>
dropMeth = uicontrol(fg, 'Style', 'popupmenu', 'Position', [col(2) rx(1) 200 txty], 'String', optMethod, 'Callback', @dropMeth_cb);
optTrcs  = {'Just this one' 'All in folder'};
dropTrcsL= uicontrol(fg, 'Style', 'text'     , 'Position', [col(3) rx(1) 100 txty], 'String', 'Traces: ', 'HorizontalAlignment', 'right', 'FontSize', 12);
dropTrcs = uicontrol(fg, 'Style', 'popupmenu', 'Position', [col(4) rx(1) 200 txty], 'String', optTrcs);

%Row 2/3: Filter Options label
label3   = uicontrol(fg, 'Style', 'text'     , 'Position', [0 rx(3) 300 txty], 'String', 'Filtering Options:', 'HorizontalAlignment', 'left', 'FontSize', 12);

%Row 4: Filter width/dec
txtFwidL= uicontrol(fg, 'Style', 'text', 'Position', [col(1) rx(4) 100 txty], 'String', 'Width (pts): ', 'HorizontalAlignment', 'right');
txtFwid = uicontrol(fg, 'Style', 'edit', 'Position', [col(2) rx(4) 200 txty], 'String', '[]');
txtFdecL= uicontrol(fg, 'Style', 'text', 'Position', [col(3) rx(4) 100 txty], 'String', 'Decimation (pts): ', 'HorizontalAlignment', 'right');
txtFdec = uicontrol(fg, 'Style', 'edit', 'Position', [col(4) rx(4) 200 txty], 'String', '10');

%Row 5/6: Options label
label5   = uicontrol(fg, 'Style', 'text'     , 'Position', [0 rx(6) 300 txty], 'String', 'Analysis Options: ', 'HorizontalAlignment', 'left', 'FontSize', 12);

%Row 7: Analysis options 1 -- will change based on which method is chosen.
txtAnOpL(1)= uicontrol(fg, 'Style', 'text', 'Position', [col(1) rx(7) 100 txty], 'String', 'FSamp: ', 'HorizontalAlignment', 'right');
txtAnOp(1) = uicontrol(fg, 'Style', 'edit', 'Position', [col(2) rx(7) 200 txty], 'String', '2500');
txtAnOpL(2)= uicontrol(fg, 'Style', 'text', 'Position', [col(3) rx(7) 100 txty], 'String', 'Bead Radii: ', 'HorizontalAlignment', 'right');
txtAnOp(2) = uicontrol(fg, 'Style', 'edit', 'Position', [col(4) rx(7) 200 txty], 'String', '[500 500]');

%Row 8: Analysis options 2
txtAnOpL(3)= uicontrol(fg, 'Style', 'text', 'Position', [col(1) rx(8) 100 txty], 'String', 'XWLC (P, S, kT, h): ', 'HorizontalAlignment', 'right');
txtAnOp(3) = uicontrol(fg, 'Style', 'edit', 'Position', [col(2) rx(8) 200 txty], 'String', '[50 900 4.14 .34]');
txtAnOpL(4)= uicontrol(fg, 'Style', 'text', 'Position', [col(3) rx(8) 100 txty], 'String', 'Extension Offset: ', 'HorizontalAlignment', 'right');
txtAnOp(4) = uicontrol(fg, 'Style', 'edit', 'Position', [col(4) rx(8) 200 txty], 'String', '0');

%Row 9/10/11: OK to exit, plus blurb
txtButOK  = uicontrol(fg, 'Style', 'pushbutton', 'Position', [col(4)+100 rx(11) 100 txty*3], 'String', 'Ok', 'Callback', @(~,~)uiresume(fg));
txtBlurb  = uicontrol(fg, 'Style', 'text', 'Position', [0 rx(11) col(4)+100 txty*3], 'String', 'Comment');

%Assign to defaults (or to match the passed opts struct)
if nargin > 0
    dropMeth.Value = find(strcmp(dropMeth.String, inOpts.Method));
    dropTrcs.Value = inOpts.Traces;
    dropMeth_cb(dropMeth);
    %Set filtering opts
    txtFwid.String = sprintf('[%d]', inOpts.fwid);
    txtFdec.String = sprintf('%d', inOpts.fdec);
    %Set per-method opts
    switch dropMeth.Value
        case 1 %Pairwise
            %Nothing, run sumPWDv1bmatrix with default opts
        case 2 %Stepfinding K-V
            if isa(inOpts.kvpf, 'single')
                txtAnOp(1).String = sprintf('single(%g)', inOpts.kvpf);
            else
                txtAnOp(1).String = sprintf('%g', inOpts.kvpf);
            end
        case 3 %Sfind KDF
            txtAnOp(1).String = sprintf('%g', inOpts.binsz);
            txtAnOp(2).String = sprintf('%g', inOpts.ksd);
            txtAnOp(3).String = sprintf('%g', inOpts.mpp);
        case 4 %Sfind HMM
            txtAnOp(1).String = sprintf('%g', inOpts.binsz);
            txtAnOp(4).String = sprintf('%g', inOpts.parpool);
        case 5 %HMM
            txtAnOp(1).String = sprintf('%d', inOpts.ns);
            txtAnOp(4).String = sprintf('%g', inOpts.parpool);
        case 6 %vdist
            txtAnOp(1).String = sprintf('{%d %d}', cell2mat(inOpts.sgp));
            txtAnOp(2).String = sprintf('%g', inOpts.vbinsz);
            txtAnOp(3).String = sprintf('%g', inOpts.Fs);
            txtAnOp(4).String = sprintf('%g', inOpts.velmult);
        otherwise
            warning('Loaded inOpts method %d is invalid', src.Value)
    end
    
else
    dropMeth.Value = 1;
    dropTrcs.Value = 1;
    dropMeth_cb(dropMeth);
end


%Wait for person to press the OK button, which calls uiresume
uiwait(fg)

%If exited with X, fg is deleted, so exit
if ~isgraphics(fg)
    opts = [];
    return
end

%Then grab, return output
opts.Method = dropMeth.String{dropMeth.Value};
opts.Traces = dropTrcs.Value;
opts.fwid = str2num(txtFwid.String);
opts.fdec = str2double(txtFdec.String);
switch dropMeth.Value
    case 1 %Pairwise
        opts.binsz = str2double(txtAnOp(1).String);
    case 2 %Stepfinding K-V
        opts.kvpf = str2num(txtAnOp(1).String); %#ok<*ST2NM>
    case 3 %Sfind KDF
        opts.binsz = str2double(txtAnOp(1).String);
        opts.ksd = str2double(txtAnOp(2).String);
        opts.mpp = str2double(txtAnOp(3).String);
    case 4 %Sfind HMM
        opts.binsz = str2double(txtAnOp(1).String);
        opts.parpool = str2double(txtAnOp(4).String);
    case 5 %HMM
        opts.ns = str2double(txtAnOp(1).String);
        opts.parpool = str2double(txtAnOp(4).String);
    case 6 %vdist
        opts.sgp = str2num(txtAnOp(1).String);
        opts.vbinsz = str2double(txtAnOp(2).String);
        opts.Fs = str2double(txtAnOp(3).String);
        opts.velmult = str2double(txtAnOp(4).String);
    otherwise
        error('Dropdown menu for Methods can''t handle value %d', opts.Value)
end

out = opts;
%Close figure
delete(fg)

%Callbacks, to set the defaults on popupmenu
%By method
    function dropMeth_cb(src,~)
        switch src.Value
            case 1 %Pairwise
                flt = 0;
                flts= {[] 5};
                ena = {'on' 'off' 'off' 'off'};
                strL= {'Bin Size' '' '' ''};
                str = {'0.1' '' '' ''};
                cmt = 'Calculate the pairwise distance distribution by the autocorrelation of the residence time histogram. Choose a bin size for the residence time histogram. It will calculate with a variety of filters. The resulting figure will be an array of graphs, with text label [DataFilter, BinSize, PWDFilter]';
            case 2 %Stepfinding K-V
                flt = 1;
                flts= {[] 5};
                ena = {'on' 'off' 'off' 'off'};
                strL= {'Penalty' '' '' ''};
                str = {'single(5)' '' '' ''};
                cmt = 'Finds steps via the Kalafut-Visscher algorithm, which places steps to minimize the quadratic error between the function and the staircase fit to it. Choose a penalty (higher = fewer steps) and a filtering (higher = more steps, suggest filter width = [].';
            case 3 %Sfind KDF
                flt = 1;
                flts= {10 1};
                ena = {'on'       'on'        'on'          'off'};
                strL= {'Bin Size' 'Kernel SD' 'MinPeakProm' ''};
                str = {'0.1'      '1'         '0.5'         ''};
                cmt = 'Finds steps by finding peaks in the kernel density. Choose the filtering [increase Width for fewer steps] a bin size for the residence time histogram, the sd of the gaussian used [smaller = ''less filtered'' kernel], and the MinPeakProm [the required difference in peak heights to be called a step, higher = more steps].';
            case 4 %Sfind HMM
                flt = 1;
                flts= {[] 5};
                ena = {'on' 'off' 'off' 'on'};
                strL= {'Bin Size' '' '' 'Multithread?'};
                str = {'0.1' '' '' '1'};
                cmt = 'Finds steps via a HMM-based method. Choose a bin size that quantizes the states. Does not do iterative optimizing, just shows the first run output. May take a long time - use multithreading if you can spare the memory/cpu time';
            case 5 %HMM
                flt = 1;
                flts= {[] 5};
                ena = {'on' 'off' 'off' 'on'};
                strL= {'N States' '' '' 'Multithread?'};
                str = {'3' '' '' '1'};
                cmt = 'Fits an N-state HMM to the data. Does not do iterative optimizing, just shows the first run output. Multithread for speed at the cost of CPU/RAM usage';
            case 6 %vdist
                flt = 0;
                flts= {[] 5};
                ena = {'on' 'on' 'on' 'on'};
                strL= {'S-G Params' 'Bin Size' 'Fs' 'velmult'};
                str = {'{ 1 301 }' '2' '2500' '1'};
                cmt = 'Calculates the velocity distribution by filtering and differentiating with a Savitzky-Golay filter with params {order, width}. The other options are for plotting of the velocity histogram, the bin size, the sampling frequency (to calculate velocity), and a velocity multiplier [e.g. set -1 to turn negative velocities positive]';
            otherwise
                error('Dropdown menu for Methods can''t handle value %d', src.Value)
        end
        %Set the options
        for ii = 1:4
            txtAnOp(ii).Enable = ena{ii};
            txtAnOp(ii).String = str{ii};
            txtAnOpL(ii).String = strL{ii};
        end
        if flt
            txtFwid.Enable = 'on';
            txtFdec.Enable = 'on';
            txtFwid.String = sprintf('[ %d ]', flts{1});
            txtFdec.String = sprintf('%d', flts{2});
        else
            txtFwid.Enable = 'off';
            txtFdec.Enable = 'off';
        end
        txtBlurb.String = cmt;
        
    end
end
