function out = lumProcess(dat, datoff)

if nargin < 2
    [f, p] = uigetfile('*.h5', 'Select offset');
    if ~p
        return
    end
    datoff = readh5all(fullfile(p,f));
elseif ischar(datoff)
    datoff = readh5all(datoff);
end

if nargin < 1
    [f, p] = uigetfile('*.h5', 'Select data');
    if ~p
        return
    end
    dat = readh5all(fullfile(p,f));
elseif ischar(dat)
    dat = readh5all(dat);
end

%Apply offset
off = lumOffset(datoff);

%Get fields
frcs = {dat.ForceHF_Force1x dat.ForceHF_Force1y dat.ForceHF_Force2x dat.ForceHF_Force2y};
mir = dat.Trapposition_N1X;
%Data is saved at 78125Hz (5^7), Downsample to 3125Hz
frcs = windowFilter(@mean, frcs, [], 25);
mir = windowFilter(@mean, mir, [], 25);

tim= (0:length(mir)-1)/3125;
%Downsample mirror values to camera values
dist = polyval(off.mirconv, mir);

%Apply offset
frco = cellfun(@(x,y) x - interp1(off.offx,y,dist, 'linear', 'extrap'), frcs, off.offy, 'Un', 0);

%Calculate sum force
frc = hypot(frco{1} - frco{3}, frco{2}-frco{4})/2;

%Calculate bead extension
%Extract calibration kappas
cal = dat.cal;
%This is a field CalibrationNN
cal = struct2cell(cal);
cal = cal{1};
%This should be a struct with fields x1 y1 x2 y2 , 

%For now, just subtract x amount, until I can actually get the position of trap 2
ext = dist - (frco{1}/cal.x1.k/1000 - frco{3}/cal.x2.k/1000) * sign(mean(frco{1} - frco{3}));

%Assign output variable
out.time = tim;
out.force = frc;
out.extension = ext;
[out.force1x, out.force1y, out.force2x, out.force2y] = frco{:};
out.cal = cal;
out.off = off;










