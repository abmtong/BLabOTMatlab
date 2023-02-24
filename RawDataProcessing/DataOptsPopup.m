function opts = DataOptsPopup()
%Create a popup to choose what instrument / data type the data has used.
%Returns an options struct that (should be able to be) directly passed to downstream functions
%See the end / run this to see the fieldnames

%Make the figure
pxx = 600;
txty = 20;
nrows = 17;
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
optInstr = {'HiRes QPD' 'Meitner' 'Boltzmann' 'Mini' 'Lumicks' 'HiRes PSD' 'HiRes bPD'};
optProt  = {'Semipassive' 'Force feedback' 'Force-Extension' 'One Trap'};
dropInstL= uicontrol(fg, 'Style', 'text'     , 'Position', [col(1) rx(1) 100 txty], 'String', 'Instrument: ', 'HorizontalAlignment', 'right', 'FontSize', 12); %#ok<*NASGU>
dropInst = uicontrol(fg, 'Style', 'popupmenu', 'Position', [col(2) rx(1) 200 txty], 'String', optInstr, 'Callback', @dropInst_cb);
dropProtL= uicontrol(fg, 'Style', 'text'     , 'Position', [col(3) rx(1) 100 txty], 'String', 'Protocol: ', 'HorizontalAlignment', 'right', 'FontSize', 12);
dropProt = uicontrol(fg, 'Style', 'popupmenu', 'Position', [col(4) rx(1) 200 txty], 'String', optProt, 'Callback', @dropProt_cb);
txtProtL= uicontrol(fg, 'Style', 'text', 'Position', [col(3) rx(2) 100 txty], 'String', 'Trap (for One Trap): ', 'HorizontalAlignment', 'right');
txtProt = uicontrol(fg, 'Style', 'edit', 'Position', [col(4) rx(2) 200 txty], 'String', 'B');

%Row 2/3: Data Options label
label3   = uicontrol(fg, 'Style', 'text'     , 'Position', [0 rx(3) 300 txty], 'String', 'Data Options:', 'HorizontalAlignment', 'left', 'FontSize', 12);

%Row 4: Booleans
tfContour = uicontrol(fg, 'Style', 'checkbox', 'Position', [ 50 rx(4) 200 txty], 'String', 'Convert to Contour');
tfSplitFC = uicontrol(fg, 'Style', 'checkbox', 'Position', [250 rx(4) 200 txty], 'String', 'Split Feedback Cycles');
tfNormalize=uicontrol(fg, 'Style', 'checkbox', 'Position', [450 rx(4) 200 txty], 'String', 'Normalize by Sum?');

%Row 5: Data Options - Fsamp, Radii
txtFsampL= uicontrol(fg, 'Style', 'text', 'Position', [col(1) rx(5) 100 txty], 'String', 'FSamp: ', 'HorizontalAlignment', 'right');
txtFsamp = uicontrol(fg, 'Style', 'edit', 'Position', [col(2) rx(5) 200 txty], 'String', '2500', 'Callback', @lumWarn);
txtRadiiL= uicontrol(fg, 'Style', 'text', 'Position', [col(3) rx(5) 100 txty], 'String', 'Bead Radii: ', 'HorizontalAlignment', 'right');
txtRadii = uicontrol(fg, 'Style', 'edit', 'Position', [col(4) rx(5) 200 txty], 'String', '[500 500]');

%Row 6: XWLC Options, Extension offset
txtXWLCpL = uicontrol(fg, 'Style', 'text', 'Position', [col(1) rx(6) 100 txty], 'String', 'XWLC (P, S, kT, h): ', 'HorizontalAlignment', 'right');
txtXWLCp  = uicontrol(fg, 'Style', 'edit', 'Position', [col(2) rx(6) 200 txty], 'String', '[50 900 4.14 .34]');
txtExtOffL= uicontrol(fg, 'Style', 'text', 'Position', [col(3) rx(6) 100 txty], 'String', 'Extension Offset: ', 'HorizontalAlignment', 'right');
txtExtOff = uicontrol(fg, 'Style', 'edit', 'Position', [col(4) rx(6) 200 txty], 'String', '0');

%Row 7/8: Calibration options label
label7    = uicontrol(fg, 'Style', 'text', 'Position', [0 rx(8) 300 txty], 'String', 'Calibration Options:', 'HorizontalAlignment', 'left', 'FontSize', 12);

%Row 9: Calibration options
%Lorentian Models
lormodels = {'No filter (Timeshared default)' 'One first-order filter' 'Delayed response filter (HiRes default)' 'Two first-order filters'};
txtLorFltL= uicontrol(fg, 'Style', 'text',      'Position', [col(1) rx(9) 100 txty], 'String', 'Lorentzian filtering: ', 'HorizontalAlignment', 'right');
txtLorFlt = uicontrol(fg, 'Style', 'popupmenu', 'Position', [col(2) rx(9) 200 txty], 'String', lormodels);
txtWaterVL= uicontrol(fg, 'Style', 'text',      'Position', [col(3) rx(9) 100 txty], 'String', 'Water Viscosity: ', 'HorizontalAlignment', 'right');
txtWaterV = uicontrol(fg, 'Style', 'edit',      'Position', [col(4) rx(9) 200 txty], 'String', '0.97e-9');
txtCFsampL=uicontrol(fg, 'Style', 'text', 'Position', [col(1) rx(10) 100 txty], 'String', 'Cal FSamp: ', 'HorizontalAlignment', 'right');
txtCFsamp= uicontrol(fg, 'Style', 'edit', 'Position', [col(2) rx(10) 200 txty], 'String', '75000', 'Callback', []);

%Row 10/11: Instrument Calibration options:
label11    = uicontrol(fg, 'Style', 'text', 'Position', [0 rx(11) 300 txty], 'String', 'Instrument Calibration:', 'HorizontalAlignment', 'left', 'FontSize', 12);

%Row 12: Trap Offset X,Y ; Trap Conversion X,Y
txtTConvXYL= uicontrol(fg, 'Style', 'text', 'Position', [col(1) rx(12) 100 txty], 'String', 'Trap Conv. [X,Y]: ', 'HorizontalAlignment', 'right');
txtTConvXY = uicontrol(fg, 'Style', 'edit', 'Position', [col(2) rx(12) 200 txty], 'String', '[1 1]');
txtTOffXYL = uicontrol(fg, 'Style', 'text', 'Position', [col(3) rx(12) 100 txty], 'String', 'Trap Offset [X,Y]: ', 'HorizontalAlignment', 'right');
txtTOffV   = uicontrol(fg, 'Style', 'edit', 'Position', [col(4) rx(12) 200 txty], 'String', '[0 0]');

%Row 13/14: Custom options label
label14    = uicontrol(fg, 'Style', 'text', 'Position', [0 rx(14) 300 txty], 'String', 'Additional Options:', 'HorizontalAlignment', 'left', 'FontSize', 12);

%Row 15: Custom options input
txtCustomL = uicontrol(fg, 'Style', 'text', 'Position', [col(1) rx(15) 100 txty], 'String', 'Custom Options: ', 'HorizontalAlignment', 'right');
txtCustom  = uicontrol(fg, 'Style', 'edit', 'Position', [col(2) rx(15) 400 txty], 'String', '{''field'', ''value'';}');

%Row 16: OK to exit
txtButOK  = uicontrol(fg, 'Style', 'pushbutton', 'Position', [col(4)+100 rx(17) 100 txty*2], 'String', 'Ok', 'Callback', @(~,~)uiresume(fg));

%Set defaults
dropInst.Value = 6; %Instrument - HiRes PSD
dropInst_cb(dropInst);
dropProt.Value = 1; %Protocol - Semipassive
dropProt_cb(dropProt);

%Wait for person to press the OK button, which calls uiresume
uiwait(fg)

%If exited with X, fg is deleted, so exit
if ~isgraphics(fg)
    opts = [];
    return
end

%Then grab, return output
%Skip some outputs that aren't enabled
opts.Instrument = dropInst.String{dropInst.Value};
opts.Protocol = dropProt.String{dropProt.Value};
if strcmp(opts.Protocol, 'One Trap')
    opts.oneTrap = txtProt.String;
end
opts.convToContour = tfContour.Value;
opts.splitFCs = tfSplitFC.Value;
if strcmp(txtFsamp.Enable, 'on')
    opts.Fsamp = str2double(txtFsamp.String);
end
  ra = str2num(txtRadii.String); %#ok<*ST2NM>
opts.raA = ra(1);
opts.raB = ra(2);
if strcmp(txtXWLCp.Enable, 'on');
    xw = str2num(txtXWLCp.String); %[P S kT h]
    opts.dnaPL = xw(1);
    opts.dnaSM = xw(2);
    opts.dnakT = xw(3);
    opts.dnaBp = xw(4);
end
opts.extOffset = str2double(txtExtOff.String);
opts.cal.lortype = txtLorFlt.Value;
opts.cal.wV = str2double(txtWaterV.String);
opts.cal.Fs = str2num(txtCFsamp.String);
  convXY = str2num(txtTConvXY.String);
opts.convTrapX = convXY(1);
opts.convTrapY = convXY(2);
  offXY = str2num(txtTOffV.String);
opts.offTrapX = offXY(1);
opts.offTrapY = offXY(2);
opts.normalize = tfNormalize.Value;

%Add Customs if passed: Passed as {fieldname , value; fieldname, value}
if ~strcmp(txtCustom.String, '{''field'', ''value'';}')
    custoptcell = eval(txtCustom.String);
    if iscell(custoptcell)
        custopts = [];
        custoptcell = reshape(custoptcell, [], 2);
        for i = 1:size(custoptcell, 1)
            eval(sprintf('custopts.%s = %s;', custoptcell{i,1}, custoptcell{i,2}))
        end
        opts = handleOpts(opts, custopts);
    else
        fprintf('Custom option parsing failed, exiting\n')
        return
    end
end

%Close figure
delete(fg)

%Callbacks, to set the defaults on popupmenu
%By instrument
    function dropInst_cb(src,~)
        switch src.Value
            case 1 %HiRes QPD
                txtFsamp.Enable = 'on';
                txtFsamp.String = '2500';
                txtTConvXY.Enable = 'on';
                txtTOffV.Enable = 'on';
                txtTConvXY.String = '[758.4 577.2]'; %Mirror calibrated 041719. Trap B offsets found by eye
                txtTOffV.String = '[1.35 1.60]'; %Changed from 1.40,1.05 on 201022, and then from 1.35, 1.60 on 230210
                txtLorFlt.Value = 1;
                txtLorFlt.Enable = 'on';
                txtWaterV.Enable = 'on';
                txtCustom.String = '{''cal.Fmax'', ''1e4'';}';
                tfNormalize.Value = 1;
                txtCFsamp.String = '70000';
            case 2 %Meitner
                txtFsamp.Enable = 'off';
                txtTConvXY.Enable = 'on';
                txtTOffV.Enable = 'off';
                txtTConvXY.String = '[160.2656 0]';
                txtTOffV.String = '[0 0]';
                txtLorFlt.Value = 1;
                txtLorFlt.Enable = 'on';
                txtWaterV.Enable = 'on';
                txtCustom.String = '{''field'', ''value'';}';
                tfNormalize.Value = 1;
                txtCFsamp.String = '200000/3';
            case 3 %Boltzmann
                warning('Should check Boltzmann Instrument Calibration values')
                txtFsamp.Enable = 'off';
                txtTConvXY.Enable = 'on';
                txtTOffV.Enable = 'off';
                txtTConvXY.String = '[142 0]';
                txtTOffV.String = '[0 0]';
                txtLorFlt.Value = 1;
                txtLorFlt.Enable = 'on';
                txtWaterV.Enable = 'on';
                txtCustom.String = '{''field'', ''value'';}';
                tfNormalize.Value = 1;
                txtCFsamp.String = '100000';
            case 4 %Mini
                txtFsamp.Enable = 'off';
                txtTConvXY.Enable = 'off';
                txtTOffV.Enable = 'off';
                txtTConvXY.String = '[0 0]';
                txtTOffV.String = '[0 0]';
                txtLorFlt.Value = 1;
                txtLorFlt.Enable = 'on';
                txtWaterV.Enable = 'on';
                txtCustom.String = '{''field'', ''value'';}';
                tfNormalize.Value = 1;
                txtCFsamp.String = '100000';
            case 5 %Lumicks
                txtFsamp.Enable = 'on';
                txtFsamp.String = '3125';
                txtTConvXY.Enable = 'off';
                txtTOffV.Enable = 'off';
                txtTConvXY.String = '[0 0]';
                txtTOffV.String = '[0 0]';
                txtLorFlt.Value = 1;
                txtLorFlt.Enable = 'off';
                txtWaterV.Enable = 'off';
                txtCustom.String = '{''field'', ''value'';}';
                tfNormalize.Value = 1;
                txtCFsamp.String = '78125';
            case 6 %HiRes PSD
                txtFsamp.Enable = 'on';
                txtFsamp.String = '2500';
                txtTConvXY.Enable = 'on';
                txtTOffV.Enable = 'on';
                txtTConvXY.String = '[758.4 577.2]'; %Mirror calibrated 041719. Trap B offsets found by eye
                txtTOffV.String = '[1.35 1.30]'; %Changed from 1.40,1.05 on 201022
                txtLorFlt.Value = 3;
                txtLorFlt.Enable = 'on';
                txtWaterV.Enable = 'on';
                txtCustom.String = '{''field'', ''value'';}';
                tfNormalize.Value = 1;
                txtCFsamp.String = '70000';
            case 7 %HiRes bPD
                txtFsamp.Enable = 'on';
                txtFsamp.String = '2500';
                txtTConvXY.Enable = 'on';
                txtTOffV.Enable = 'on';
                txtTConvXY.String = '[758.4 577.2]'; %Mirror calibrated 041719. Trap B offsets found by eye
                txtTOffV.String = '[1.35 1.30]'; %Changed from 1.40,1.05 on 201022
                txtLorFlt.Value = 1;
                txtLorFlt.Enable = 'on';
                txtWaterV.Enable = 'on';
                txtCustom.String = '{''cal.Fmax'', ''1e4'';}';
                tfNormalize.Value = 0;
                txtCFsamp.String = '70000';
            otherwise
                error('Dropdown menu for Instruments can''t handle value %d', src.Value)
        end
        
    end

%By protocol
    function dropProt_cb(src, ~)
        switch src.Value
            case 1 %Semipassive
                txtXWLCp.Enable = 'on';
                tfContour.Value = true;
                tfSplitFC.Value = true;
                txtExtOff.String = '50';
                txtProt.Enable = 'off';
            case 2 %Force feedback
                txtXWLCp.Enable = 'on';
                tfContour.Value = true;
                tfSplitFC.Value = false;
                txtExtOff.String = '50';
                txtProt.Enable = 'off';
            case 3 %Force-extension
                txtXWLCp.Enable = 'off';
                tfContour.Value = false;
                tfSplitFC.Value = false;
                txtExtOff.String = '0';
                txtProt.Enable = 'off';
            case 4 %One trap
                txtXWLCp.Enable = 'off';
                tfContour.Value = false;
                tfSplitFC.Value = false;
                txtExtOff.String = '0';
                txtProt.Enable = 'on';
            otherwise
                error('Dropdown menu for Protocols can''t handle value %d', src.Value)
        end
    end

%Lumicks warning
    function lumWarn(src,~)
        if strcmp('Lumicks', dropInst.String{dropInst.Value})
            dsamp = (78125 / str2double(src.String));
            if round(dsamp) ~= dsamp
                warning('Will pick the closest usable output frequency: %0.2fHz', 78125/max(round(dsamp), 1));
            end
        end
    end
end