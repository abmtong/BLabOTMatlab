function out = CalStepwise(indat, inOpts)
%HMm can't actually use this [yet] as the instrument won't do step + cal simultaneously

opts = [];
if nargin > 1
    opts = handleOpts(opts, inOpts);
end

Fs = indat.inf.FramerateHz;

%Split by stepwise protocol, then send each section to CalElro
params = procparams(indat.inf.Mode, indat.inf.Parameters);
opts.tdwell = params.tdwell;
opts.stepsz = params.stepsz;
opts.rotdir = 2*strcmp('Hydrolysis', params.dir) -1; %+ for hy, - for syn

dwlen = floor(Fs * opts.tdwell);

rot = indat.rotlong * 360;
len = length(rot);
stInd = 1:dwlen:len;
stInd = stInd(2:end);
hei = length(stInd)-1;
cals = cell(1,hei);
poss = zeros(1,hei);
aks = zeros(1,hei);
als = zeros(1,hei);
kas = zeros(1,hei);

calopts.verbose = 0;
calopts.Fs = 4e3;


for i = 1:hei
    tmpel = indat;
    tmp = rot(stInd(i):stInd(i+1)-1);
    poss(i) = mean(tmp);
    tmpel.rotlong = tmp;
%     cals{i} = Calibrate(tmp, calopts);
%     aks(i) = cals{i}.a * cals{i}.k;
%     als(i) = cals{i}.a;
%     kas(i) = cals{i}.k;
%     
%     cals{i} = CalElro(tmpel, opts);
end

tpos = (1:hei) * opts.stepsz * opts.rotdir;
pt = poss - tpos;
phs = mod(round(pt/180),2);
pt = pt - round(pt/180)*180;
%adjust for other side of trap
tpos(phs==1) = tpos(phs==1) +180;


figure
scatter(mod(tpos, 360), pt )
hold on
mnmx = [min(pt) , max(pt)];
% plot(mod(tpos,360), rescale(aks, mnmx ))
% plot(mod(tpos,360), rescale(als, mnmx))
% plot(mod(tpos,360), rescale(kas, mnmx))
