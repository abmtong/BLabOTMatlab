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
optInstr = {'HiRes' 'Meitner' 'Boltzmann' 'Mini' 'Lumicks'};
optProt  = {'Semipassive' 'Force feedback' 'Force-Extension'};
dropInstL= uicontrol(fg, 'Style', 'text'     , 'Position', [col(1) rx(1) 100 txty], 'String', 'Instrument: ', 'HorizontalAlignment', 'right', 'FontSize', 12); %#ok<*NASGU>
dropInst = uicontrol(fg, 'Style', 'popupmenu', 'Position', [col(2) rx(1) 200 txty], 'String', optInstr, 'Callback', @dropInst_cb);
dropProtL= uicontrol(fg, 'Style', 'text'     , 'Position', [col(3) rx(1) 100 txty], 'String', 'Protocol: ', 'HorizontalAlignment', 'right', 'FontSize', 12);
dropProt = uicontrol(fg, 'Style', 'popupmenu', 'Position', [col(4) rx(1) 200 txty], 'String', optProt, 'Callback', @dropProt_cb);

%Row 2/3: Data Options label
label3   = uicontrol(fg, 'Style', 'text'     , 'Position', [0 rx(3) 300 txty], 'String', 'Data Options:', 'HorizontalAlignment', 'left', 'FontSize', 12);

%Row 4: Booleans
tfContour = uicontrol(fg, 'Style', 'checkbox', 'Position', [ 50 rx(4) 200 txty], 'String', 'Convert to Contour');
tfSplitFC = uicontrol(fg, 'Style', 'checkbox', 'Position', [250 rx(4) 200 txty], 'String', 'Split Feedback Cycles');

%Row 5: Data Options - Fsamp, Radii
txtFsampL= uicontrol(fg, 'Style', 'text', 'Position', [col(1) rx(5) 100 txty], 'String', 'FSamp: ', 'HorizontalAlignment', 'right');
txtFsamp = uicontrol(fg, 'Style', 'edit', 'Position', [col(2) rx(5) 200 txty], 'String', '2500');
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
dropInst.Value = 1; %Protocol
dropInst_cb(dropInst);
dropProt.Value = 1; %Feedback
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
  convXY = str2num(txtTConvXY.String);
opts.convTrapX = convXY(1);
opts.convTrapY = convXY(2);
  offXY = str2num(txtTOffV.String);
opts.offTrapX = offXY(1);
opts.offTrapY = offXY(2);

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
            case 1 %HiRes
                txtFsamp.Enable = 'on';
                txtTConvXY.Enable = 'on';
                txtTOffV.Enable = 'on';
                txtTConvXY.String = '[758.4 577.2]'; %Mirror calibrated 041719. Trap B offsets found by eye
                txtTOffV.String = '[1.35 1.30]'; %Changed from 1.40,1.05 on 201022
                txtLorFlt.Value = 3;
            case 2 %Meitner
                txtFsamp.Enable = 'off';
                txtTConvXY.Enable = 'on';
                txtTOffV.Enable = 'off';
                txtTConvXY.String = '[160.2656 0]';
                txtTOffV.String = '[0 0]';
                txtLorFlt.Value = 1;
            case 3 %Boltzmann
                warning('Should check Boltzmann Instrument Calibration values')
                txtFsamp.Enable = 'off';
                txtTConvXY.Enable = 'on';
                txtTOffV.Enable = 'off';
                txtTConvXY.String = '[152 0]';
                txtTOffV.String = '[0 0]';
                txtLorFlt.Value = 1;
            case 4 %Mini
                txtFsamp.Enable = 'off';
                txtTConvXY.Enable = 'off';
                txtTOffV.Enable = 'off';
                txtTConvXY.String = '[0 0]';
                txtTOffV.String = '[0 0]';
                txtLorFlt.Value = 1;
            case 5 %Lumicks
                txtFsamp.Enable = 'off';
                txtTConvXY.Enable = 'off';
                txtTOffV.Enable = 'off';
                txtTConvXY.String = '[0 0]';
                txtTOffV.String = '[0 0]';
                txtLorFlt.Value = 1;
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
            case 2 %Force feedback
                txtXWLCp.Enable = 'on';
                tfContour.Value = true;
                tfSplitFC.Value = false;
                txtExtOff.String = '50';
            case 3 %Force-extension
                txtXWLCp.Enable = 'off';
                tfContour.Value = false;
                tfSplitFC.Value = false;
                txtExtOff.String = '0';
            otherwise
                error('Dropdown menu for Protocols can''t handle value %d', src.Value)
        end
    end
end