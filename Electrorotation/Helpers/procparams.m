function outopts = procparams(mode, params)

%Can also just pass inf, or eldata
if nargin < 2
    if isfield(mode, 'Mode')
        try
            params = mode.Parameters;
            mode = mode.Mode;
        catch
            error('Invalid input to %s', mfilename);
        end
    elseif isfield(mode, 'inf')
        try
            params = mode.inf.Parameters;
            mode = mode.inf.Mode;
        catch
            error('Invalid input to %s', mfilename);
        end
    else
        error('Invalid input to %s', mfilename);
    end
end

outopts=[];
outopts.mode = mode;
switch mode
    case 'Stepwise'
        [pms, pos] = textscan(params, '%f V^2, %s step = %f deg, %f s');
        outopts.v = pms{1}; %V^2, amplitude of trap
        outopts.dir = pms{2}{1}(1:end-1); %'Synthesis' or 'Hydrolysis'
        outopts.stepsz = pms{3}; %Degrees per step
        outopts.tdwell = pms{4}; %Time of each step, s
    case 'Constant Speed'
        [pms, pos] = textscan(params, '%f V^2, %f Hz, %s');
        outopts.v = pms{1}; %V^2, amplitude of trap
        outopts.rspd = pms{2}; %Rotation speed, Hz
        outopts.dir = pms{3}{1}; %Syn or Hyd
    case 'Fixed' %Fixed with small modulation
        [pms, pos] = textscan(params, '%f V^2, %f deg, Mod = %f Hz, %f deg');
        outopts.v = pms{1}; %V^2, amplitude of trap
        outopts.pos = pms{2}; %deg, position of hold
        outopts.modf = pms{3}; %hz, pos modulation
        outopts.moda = pms{4}; %degrees, pos modulation
    case 'Designed'
        [pms, pos] = textscan(params, '%f V^2, %f Hz, %s %s');
        outopts.v = pms{1};
        outopts.rspd = pms{2};
        outopts.dir = pms{3}{1}(1:end-1);
        outopts.prot = pms{4}{1};
        [~, tmpf , ~] = fileparts(outopts.prot);
        outopts.protfile = [tmpf(1:end-9) '.mat'];
    case 'Step V'
        [pms, pos] = textscan(params, '%f V^2, %f Hz, %f deg');
        outopts.v = pms{1};
        outopts.sspd = pms{2};
        outopts.pos = pms{3};
    otherwise
        warning('Invalid Mode')
        pos = -1;
end
        
if pos ~= length(params)
    outopts.paramsread = -1;
    warning('Params not read correctly in this file')
end
