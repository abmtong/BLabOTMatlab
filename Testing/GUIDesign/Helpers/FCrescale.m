function [sd, outcon, factor] = FCrescale( inpf, cropstr, medfrc )
%Rescale ext so the FCs align, i.e. the distance moved by the mirror matches the distance moved by the phage
%inputs: stepdata filepath, crop string, median force to use as reference

%At the same force, the change in extension = change in mirror movement

if nargin < 1
    [f, p] = uigetfile('phage*.mat');
    inpf = [p f];
    if ~p
        return
    end
end

[p, f, ~] = fileparts(inpf);
%Load file
sd = load(inpf, 'stepdata');
sd = sd.stepdata;


if nargin < 2
    cropstr = [];
end


%Load crop
fid = fopen(sprintf('%s\\CropFiles%s\\%s.crop',p, cropstr, f(6:end)));
if fid == -1
    fprintf('No Crop%s for %s\n', cropstr, f)
    sd=[];
    return
end
ts = textscan(fid, '%f');
fclose(fid);
crop = ts{1};

%apply crop
%find start/end crop indicies
indsta = cellfun(@(x)find(x>crop(1),1),        sd.time,'Uni',0);
indend = cellfun(@(x)find(x<crop(2),1,'last'), sd.time,'Uni',0);
%exract con/tim/frc values
con = cellfun(@(ce,st,en)ce(st:en),sd.contour, indsta, indend, 'Uni',0);
frc = cellfun(@(ce,st,en)ce(st:en),sd.force, indsta, indend, 'Uni',0);
tim = cellfun(@(ce,st,en)ce(st:en),sd.time, indsta, indend, 'Uni',0);
% ext = cellfun(@(ce,st,en)ce(st:en),sd.extension, indsta, indend, 'Uni',0);

% mir = sd.mxpos;
if nargin < 3
    medfrc = median([frc{:}]);
end
df = 0.1; %sum over medfrc +- df

% avgext = cellfun(@(ex, fr) mean( ex( fr < medfrc + df & fr > medfrc - df) ), ext, frc);
avgtim = cellfun(@(ex, fr) mean( ex( fr < medfrc + df & fr > medfrc - df) ), tim, frc);
avgcon = cellfun(@(ex, fr) mean( ex( fr < medfrc + df & fr > medfrc - df) ), con, frc);
%get avg vel of total in bp/s
ind1 = find(~isnan(avgtim), 1, 'first');
ind2 = find(~isnan(avgtim), 1, 'last');

ctot = avgcon(ind1) - avgcon(ind2);
ttot = avgtim(ind1) - avgtim(ind2);

%get avg vel of good part in bp/s
% [vp, vx] = vdist(con);
% vbar = sum(vp .* vx / sum(vp));

% vbar = sum(vp(vx<0) .* vx(vx<0) / sum (vp(vx<0)));

vbar = cellfun(@(x)sgolaydiff(x, {1 101}), con, 'un', 0);
vbar = mean([vbar{:}])*2500; %Fs

factor = (ctot/ttot) / vbar;

%rescale contour , all of it
outcon = cellfun(@(x) (x - x(1)) * factor + x(1), sd.contour, 'uni', 0);
if isfield(sd, 'cut')
    %do same but for cut parts
    %cant @vidst on cut parts, bc too small sample. Instead, guess at velocity with dCon and dTime
    conc = sd.cut.contour(ind1+1:ind2-1);
    if ~isempty(conc)
        %     frcc = cellfun(@(ce,st,en)ce(st:en),sd.cut.force, indsta, indend, 'Uni',0);
        %     timc = cellfun(@(ce,st,en)ce(st:en),sd.cut.time, indsta, indend, 'Uni',0);
        timc = sd.cut.time(ind1+1:ind2-1);
        t1 = cellfun(@(x) x(1), timc);
        t2 = cellfun(@(x) x(end), timc);
        c1 = cellfun(@(x) x(1), conc);
        c2 = cellfun(@(x) x(end), conc);
        
        vbarc = sum(c1-c2) / sum(t1-t2);
        factorc = (ctot/ttot) / vbarc;
        outconcut = cellfun(@(x) (x - x(end)) * factorc + x(end), sd.cut.contour, 'uni', 0);
        sd.cut.contourold = sd.cut.contour;
        sd.cut.contour = outconcut;
    end
end
sd.contourold = sd.contour;
sd.contour = outcon;
end

